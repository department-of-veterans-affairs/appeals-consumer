# frozen_string_literal: true

describe Topics::DecisionReviewCreatedTopic::DecisionReviewCreatedEvent, type: :model do
  describe "#process!" do
    let(:event) { FactoryBot.create(:decision_review_created_event) }
    let(:dto_builder_instance) { instance_double("Builders::DecisionReviewCreatedDtoBuilder") }
    let(:caseflow_response) { instance_double("Response", code: 201, message: "Some message") }

    before do
      allow(Builders::DecisionReviewCreatedDtoBuilder).to receive(:new).with(event).and_return(dto_builder_instance)
      allow(ExternalApi::CaseflowService)
        .to receive(:establish_decision_review_created_records_from_event!)
        .with(dto_builder_instance)
        .and_return(caseflow_response)
    end

    context "when processing is successful" do
      it "updates the event with a completed_at timestamp" do
        event.process!

        expect(event.completed_at).not_to be_nil
      end
    end

    context "when a ClientRequestError is raised" do
      let(:error_message) { "Client Request Error" }

      before do
        allow(ExternalApi::CaseflowService)
          .to receive(:establish_decision_review_created_records_from_event!)
          .and_raise(AppealsConsumer::Error::ClientRequestError.new({ message: error_message }))
      end

      it "logs the error and updates the event error field" do
        expect { event.process! }.to raise_error(AppealsConsumer::Error::ClientRequestError)
      end
    end

    context "when an unexpected error occurs" do
      let(:standard_error) { StandardError.new("Unexpected error") }
      let(:error_message) { "Unexpected error" }

      before do
        allow(ExternalApi::CaseflowService)
          .to receive(:establish_decision_review_created_records_from_event!)
          .and_raise(standard_error)
        allow(ExternalApi::CaseflowService)
          .to receive(:establish_decision_review_created_event_error!)
          .with(event.id, JSON.parse(event.message_payload)["claim_id"], error_message)
          .and_return(caseflow_response)
      end

      it "logs the error" do
        expect { event.process! }.to raise_error(StandardError)
      end
    end
  end
end
