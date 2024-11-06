# frozen_string_literal: true

describe Events::PersonUpdatedEvent, type: :model do
  let(:event) { build(:person_updated_event) }

  describe "#process!" do
    let(:dto_builder_instance) { instance_double("Builders::PersonUpdated::DtoBuilder") }
    let(:caseflow_response) { instance_double("Response", code: 201, message: "Some message") }
    subject { event.process! }

    before do
      allow(Builders::PersonUpdated::DtoBuilder).to receive(:new).with(event).and_return(dto_builder_instance)
      allow(ExternalApi::CaseflowService)
        .to receive(:establish_person_updated_records_from_event!)
        .with(dto_builder_instance)
        .and_return(caseflow_response)
    end

    context "when processing is successful" do
      before do
        allow(Rails.logger).to receive(:info).with(/#{message}/)
        subject
      end

      let(:message) { "Received #{caseflow_response.code}" }

      it "logs the response code" do
        expect(Rails.logger).to have_received(:info).with(/#{message}/)
      end

      it "updates the event with a completed_at timestamp" do
        expect(event.completed_at).not_to be_nil
      end
    end

    context "when a ClientRequestError is raised" do
      let(:error) { AppealsConsumer::Error::ClientRequestError }
      let(:error_message) { "Client Request Error" }

      before do
        allow(Rails.logger).to receive(:error)
        allow(ExternalApi::CaseflowService)
          .to receive(:establish_person_updated_records_from_event!)
          .and_raise(AppealsConsumer::Error::ClientRequestError.new({ message: error_message }))
      end

      it "logs and raises the error" do
        expect { subject }.to raise_error(AppealsConsumer::Error::ClientRequestError)
        expect(Rails.logger).to have_received(:error).with(/#{error_message}/)
      end
    end

    context "when an unexpected error occurs" do
      let(:standard_error) { StandardError.new("Unexpected error") }
      let(:error_message) { "Unexpected error" }

      before do
        allow(Rails.logger).to receive(:error)
        allow(ExternalApi::CaseflowService)
          .to receive(:establish_person_updated_records_from_event!)
          .and_raise(standard_error)
        allow(ExternalApi::CaseflowService)
          .to receive(:establish_person_updated_event_error!)
          .with(event.id, JSON.parse(event.message_payload)["participant_id"], error_message)
          .and_return(caseflow_response)
      end

      it "logs and raises the error and sends request to caseflow's person updated error endpoint" do
        expect { subject }.to raise_error(StandardError)
        expect(ExternalApi::CaseflowService)
          .to have_received(:establish_person_updated_event_error!)
          .with(event.id, JSON.parse(event.message_payload)["participant_id"], error_message)
        expect(Rails.logger).to have_received(:error).with(/#{standard_error}/)
      end
    end
    context "when person_updated_event_pending? is true" do
      let(:event) do
        build(
          :person_updated_event,
          message_payload: { participant_id: participant_id, update_time: update_time },
          participant_id: participant_id
        )
      end
      let(:created_event) do
        create(
          :person_updated_event,
          message_payload: { participant_id: participant_id },
          participant_id: participant_id,
          state: "NOT_STARTED",
          completed_at: nil
        )
      end
      let(:participant_id) { "1129318238" }
      let(:update_time) { "2023-07-01T00:00:00Z" }
      let(:error_message) { "Event IDs still needing processing: #{created_event.id}" }

      before do
        created_event
        allow(EventAudit).to receive(:create!).and_call_original
      end

      it "raises an error" do
        expect { event.process! }.to raise_error(AppealsConsumer::Error::PriorPersonUpdatedEventsStillPendingError)
      end
    end
  end

  describe "#person_updated_events_pending?" do
    let(:event) do
      build(
        :person_updated_event,
        message_payload: { participant_id: participant_id, update_time: update_time },
        participant_id: participant_id
      )
    end
    let(:participant_id) { "1129318238" }
    let(:update_time) { "2023-07-01T00:00:00Z" }
    let(:current_event) { double("Event", update_time: update_time) }

    context "when no events match the criteria" do
      it "returns false" do
        expect(event.send("person_updated_events_pending?")).to be_falsey
      end
    end

    context "when there is a PersonUpdatedEvent with matching criteria" do
      before do
        create(
          :person_updated_event,
          message_payload: { participant_id: participant_id },
          participant_id: participant_id,
          state: "NOT_STARTED",
          completed_at: nil
        )
      end

      it "returns true" do
        expect(event.send("person_updated_events_pending?")).to be_truthy
      end
    end

    context "when there is a PersonUpdatedEvent with matching criteria" do
      before do
        create(
          :person_updated_event,
          participant_id: participant_id,
          message_payload: { "update_time" => "2022-06-01T00:00:00Z" },
          state: "IN_PROGRESS",
          completed_at: nil
        )
      end

      it "returns true" do
        expect(event.send("person_updated_events_pending?")).to be_truthy
      end
    end

    context "when there are events with states other than the specified ones" do
      before do
        create(
          :person_updated_event,
          message_payload: { participant_id: participant_id },
          participant_id: participant_id,
          state: "PROCESSED",
          completed_at: nil
        )
        create(
          :person_updated_event,
          participant_id: participant_id,
          message_payload: { "update_time" => "2022-06-01T00:00:00Z" },
          state: "PROCESSED",
          completed_at: nil
        )
      end

      it "returns false" do
        expect(event.send("person_updated_events_pending?")).to be_falsey
      end
    end
    context "when there are events with non-nil completed_at timestamps" do
      before do
        create(
          :person_updated_event,
          message_payload: { participant_id: participant_id },
          participant_id: participant_id,
          state: "NOT_STARTED",
          completed_at: Time.current
        )
        create(
          :person_updated_event,
          participant_id: participant_id,
          message_payload: { "update_time" => "2022-06-01T00:00:00Z" },
          state: "PROCESSED",
          completed_at: Time.current
        )
      end

      it "returns false" do
        expect(event.send("person_updated_events_pending?")).to be_falsey
      end
    end
  end
end
