# frozen_string_literal: true

describe Events::DecisionReviewUpdatedEvent, type: :model do
  let(:event) { build(:decision_review_updated_event) }

  describe "#process!" do
    let(:dto_builder_instance) { instance_double("Builders::DecisionReviewUpdated::DtoBuilder") }
    let(:caseflow_response) { instance_double("Response", code: 201, message: "Some message") }
    subject { event.process! }

    before do
      allow(Builders::DecisionReviewUpdated::DtoBuilder).to receive(:new).with(event).and_return(dto_builder_instance)
      allow(ExternalApi::CaseflowService)
        .to receive(:edit_records_from_decision_review_updated_event!)
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
          .to receive(:edit_records_from_decision_review_updated_event!)
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
          .to receive(:edit_records_from_decision_review_updated_event!)
          .and_raise(standard_error)
      end

      it "logs and raises the error" do
        expect { subject }.to raise_error(StandardError, "Unexpected error")
        expect(Rails.logger).to have_received(:error).with(/#{error_message}/)
      end
    end
  end
end
