# frozen_string_literal: true

RSpec.describe Event, type: :model do
  describe "#save" do
    subject { Event.new(type: nil, message_payload: nil, partition: 1, offset: 1) }

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
        let(:my_event_audits) { create_list(:event_audit, 3, event: my_event) }

        it "event should NOT be 'failed'" do
          ClimateControl.modify MAX_ERRORS_FOR_FAILURE: "3" do
            expect(my_event.failed?).to eq false
          end
        end
      end

      context "when there are MAX_ERRORS_FOR_FAILURE, non-null error fields on event audits" do
        let(:my_event_audits) { create_list(:event_audit, 3, event: my_event, status: "failed") }

        it "event should be 'failed'" do
          ClimateControl.modify MAX_ERRORS_FOR_FAILURE: "3" do
            expect(my_event.failed?).to eq false
          end
        end
      end
    end
  end

  describe "#determine_job" do
    let(:event) { create(:event, type: "SomeNamespace::Test") }

    context "when the job class exists" do
      let!(:job_class) { class_double("TestProcessingJob").as_stubbed_const }

      it "returns the job class" do
        expect(event.determine_job).to eq(job_class)
      end
    end

    context "when the job class does not exist" do
      before do
        allow(Rails.logger).to receive(:error)
      end

      it "logs an error and returns nil" do
        expect(event.determine_job).to be_nil
        expect(Rails.logger).to have_received(:error).with(
          /No processing job found for type: Test. Please define a .TestProcessingJob for the Event class./
        )
      end
    end
  end

  describe "#process!" do
    it "raises a NoMethodError to enforce subclass implementation" do
      expect { Event.new.process! }.to raise_error(NoMethodError, /Please define a .process! method/)
    end
  end

  context "when subclassing Event" do
    let(:subclass) do
      Class.new(Event) do
        def self.process!
          "Processed"
        end
      end
    end

    it "allows the subclass to implement .process!" do
      expect { subclass.process! }.not_to raise_error
      expect(subclass.process!).to eq("Processed")
    end
  end

  describe "#in_progress!" do
    it "updates the state to in_progress" do
      event = create(:event)
      event.in_progress!
      expect(event.reload.state).to eq("in_progress")
    end
  end

  describe "#processed!" do
    it "updates the state to processed" do
      event = create(:event)
      event.processed!
      expect(event.reload.state).to eq("processed")
    end
  end

  describe "#error!" do
    it "updates the state to error" do
      event = create(:event)
      event.send(:error!)
      expect(event.reload.state).to eq("error")
    end
  end

  describe "#failed!" do
    it "updates the state to failed" do
      event = create(:event)
      event.send(:failed!)
      expect(event.reload.state).to eq("failed")
    end
  end

  describe "#message_payload_hash" do
    let(:event) { create(:event) }
    subject { event.message_payload_hash }

    context "when message_payload is stored as a json string" do
      it "returns message_payload as a hash" do
        expect(subject.class).to eq(Hash)
      end
    end

    context "when message_payload is stored as a hash" do
      before do
        event.message_payload = JSON.parse(event.message_payload)
      end

      it "returns message_payload as a hash" do
        expect(subject.class).to eq(Hash)
      end
    end
  end

  describe "handle_failure(error_message)" do
    before do
      event.in_progress!
    end

    let(:event) { create(:event) }
    subject { event.handle_failure("error message") }

    it "updates the event error column with the error_message" do
      subject
      expect(event.error).to eq("error message")
    end

    context "when the number of event audits is less than MAX_ERRORS_FOR_FAILURE" do
      let!(:event_audits) { create_list(:event_audit, 2, event: event, status: "failed") }

      it "event's state should be updated to 'error'" do
        expect(event.state).to eq("in_progress")
        subject
        ClimateControl.modify MAX_ERRORS_FOR_FAILURE: "3" do
          expect(event.state).to eq("error")
        end
      end
    end

    context "when the number of event audits is greater than or equal to MAX_ERRORS_FOR_FAILURE" do
      context "the last three event audits have an error in the error column" do
        let!(:event_audits) { create_list(:event_audit, 6, event: event, status: "failed") }

        it "event's state should be updated to 'failed'" do
          expect(event.state).to eq("in_progress")
          subject
          ClimateControl.modify MAX_ERRORS_FOR_FAILURE: "3" do
            expect(event.state).to eq("failed")
          end
        end
      end

      context "and one of the last three event audits do not have an error in the error column" do
        let!(:errored_event_audit) { create(:event_audit, event: event, status: "failed") }
        let!(:non_errored_event_audits) { create_list(:event_audit, 3, event: event) }

        it "event's state should be updated to 'error'" do
          expect(event.state).to eq("in_progress")
          subject
          ClimateControl.modify MAX_ERRORS_FOR_FAILURE: "3" do
            expect(event.state).to eq("error")
          end
        end
      end
    end
  end

  describe "#handle_response(reponse)" do
    subject { event.handle_response(caseflow_response) }
    let(:caseflow_response) { instance_double("Response", code: 401, message: "Some message") }
    let(:message) { "Received #{caseflow_response.code}" }
    let(:event) { create(:event) }

    before do
      allow(Rails.logger).to receive(:info).with(/#{message}/)
      subject
    end

    it "logs the response code" do
      expect(Rails.logger).to have_received(:info).with(/#{message}/)
    end

    context "when the response code is 201" do
      let(:caseflow_response) { instance_double("Response", code: 201, message: "Some message") }

      it "updates the event's completed_at" do
        expect(event.completed_at).not_to eq nil
      end
    end
  end
end
