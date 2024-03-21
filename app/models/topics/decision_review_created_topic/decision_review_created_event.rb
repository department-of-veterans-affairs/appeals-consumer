# frozen_string_literal: true

# A subclass of Event, representing the DecisionReviewCreated Kafka topic event.
class Topics::DecisionReviewCreatedTopic::DecisionReviewCreatedEvent < Event
  def process!
    dto = Builders::DecisionReviewCreatedDtoBuilder.new(self)
    response = ExternalApi::CaseflowService.establish_decision_review_created_records_from_event!(dto)

    handle_response(response)
  rescue AppealsConsumer::Error::ClientRequestError => error
    Rails.logger.error(error)
    raise error
  rescue StandardError => error
    Rails.logger.error(error)
    ExternalApi::CaseflowService.establish_decision_review_created_event_error!(
      id,
      message_payload_hash["claim_id"],
      error.message
    )
    raise error
  end
end
