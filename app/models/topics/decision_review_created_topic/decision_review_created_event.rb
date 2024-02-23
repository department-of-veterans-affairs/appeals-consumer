# frozen_string_literal: true

# A subclass of Event, representing the DecisionReviewCreated Kafka topic event.
class Topics::DecisionReviewCreatedTopic::DecisionReviewCreatedEvent < Event
  def process!
    dto = Builders::DecisionReviewCreatedDtoBuilder.new(self)
    response = ExternalApi::CaseflowService.establish_decision_review_created_records_from_event!(dto)

    handle_response(response)
  rescue AppealsConsumer::Error::ClientRequestError => error
    handle_client_error(error.message)
  rescue StandardError => error
    ExternalApi::CaseflowService.establish_decision_review_created_event_error!(
      id,
      JSON.parse(message_payload)["claim_id"],
      error.message
    )
    Rails.logger.error(error.message)
  end
end
