# frozen_string_literal: true

RSpec.describe Event, type: :model do
  describe "#save" do
    subject { Event.new(type: nil, message_payload: nil) }

    it "should fail creating an event with empty type" do
      subject.message_payload = "{\"something\": 1}"
      expect(subject.valid?).to eq false
      expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "should fail creating an event with empty message_payload" do
      subject.type = "some_type"
      expect(subject.valid?).to eq false
      expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "should fail creating an event_audit with incorrect status" do
      subject.type = "some_type"
      subject.message_payload = { "claim_id" => 123 }
      expect(subject.valid?).to eq true
      expect { subject.state = "some_random_status" }.to raise_error(ArgumentError)
      subject.save!
      expect(subject.state).to eq "not_started"
    end

    it "should have a default status of 'not_started'" do
      expect(subject.state).to eq "not_started"
    end
  end

  describe "#event_audits" do
    let!(:my_event) { create(:event) }
    let!(:my_event_audits) { create_list(:event_audit, 2, event: my_event) }

    it "should associate with it's event_audits" do
      expect(my_event.event_audits).to eq my_event_audits
    end

    it "should have event_audits that have a bi-directional relationship with itself" do
      expect(my_event.event_audits.first.event_id).to eq my_event.id
      expect(my_event.event_audits.last.event_id).to eq my_event.id
    end
  end

  describe "#processed?" do
    let!(:my_event) { create(:event) }

    context "when an event is NOT completed" do
      it "should not be processed" do
        expect(my_event.processed?).to eq false
      end
    end

    context "when an event is completed" do
      it "should be processed" do
        my_event.update(completed_at: Time.current)
        expect(my_event.processed?).to eq true
      end
    end
  end

  describe "#failed?" do
    let!(:my_event) { create(:event) }

    context "when the number of event audits are less than MAX_ERRORS_FOR_FAILURE" do
      let(:my_event_audits) { create_list(:event_audit, 2, event: my_event) }

      it "event should NOT be 'failed'" do
        ClimateControl.modify MAX_ERRORS_FOR_FAILURE: "2" do
          expect(my_event.event_audits.size < ENV["MAX_ERRORS_FOR_FAILURE"].to_i).to eq true
          expect(my_event.failed?).to eq false
        end
      end
    end

    context "when the number of event audits are more than MAX_ERRORS_FOR_FAILURE" do
      context "when there are NOT MAX_ERRORS_FOR_FAILURE, non-null error fields on event audits" do
        let(:my_event_audits) { create_list(:event_audit, 3, event: my_event, error: "some failure message") }

        it "event should NOT be 'failed'" do
          ClimateControl.modify MAX_ERRORS_FOR_FAILURE: "3" do
            my_event_audits.last.update(error: nil)
            expect(my_event.failed?).to eq false
          end
        end
      end

      context "when there are MAX_ERRORS_FOR_FAILURE, non-null error fields on event audits" do
        let(:my_event_audits) { create_list(:event_audit, 3, event: my_event, error: "some failure message") }

        it "event should be 'failed'" do
          ClimateControl.modify MAX_ERRORS_FOR_FAILURE: "3" do
            expect(my_event.failed?).to eq false
          end
        end
      end
    end
  end

  describe "#process!" do
    let(:event) { FactoryBot.create(:event) }
    let(:dto_builder_instance) { instance_double("Builders::DecisionReviewCreatedDTOBuilder") }
    let(:caseflow_response) { instance_double("Response", code: response_code, message: "Some message") }

    before do
      allow(Builders::DecisionReviewCreatedDTOBuilder).to receive(:new).with(event).and_return(dto_builder_instance)
      allow(CaseflowService)
        .to receive(:establish_decision_review_created_records_from_event!)
        .with(dto_builder_instance)
        .and_return(caseflow_response)
    end

    context "when processing is successful" do
      let(:responce_code) { 201 }

      it "updates the event with a completed_at timestamp" do
        Timecop.freeze do
          expect { event.process! }.to change(event, :completed_at).from(nil).to(Time.zone.now)
        end
      end
    end

    context "when a ClientRequestError is raised" do
      let(:response_code) { 500 }
      let(:error_message) { "Client Request Error" }

      before do
        allow(CaseflowService)
          .to receive(:establish_decision_review_created_records_from_event!)
          .and_raise(AppealsConsumer::Error::ClientRequestError.new(error_message))
      end

      it "logs the error and updates the event error field" do
        expect(Rails.logger).to receive(:error).with(error_message)
        expect { event.process! }.to change(event, :error).from(nil).to(error_message)
      end
    end

    context "when an unexpected error occurs" do
      let(:response_code) { 500 }
      let(:standard_error) { StandardError.new("Unexpected error") }
      let(:error_message) { "Unexpected error" }

      before do
        allow(CaseflowService)
          .to receive(:establish_decision_review_created_records_from_event!)
          .and_raise(standard_error)
        allow(CaseflowService)
          .to received(:establish_decision_review_created_event_error!)
          .with(event.id, event.message_payload["claim_id"], error_message)
          .and_return(caseflow_response)
      end

      it "logs the error" do
        expect(Rails.logger).to receive(:error).with(error_message)
        expect { event.process! }.not_to raise_error
      end
    end
  end
end
