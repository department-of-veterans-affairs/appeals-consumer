# frozen_string_literal: true

# A subclass of Event, representing the DecisionReviewCreated Kafka topic event.
class Topics::DecisionReviewCreatedTopic::DecisionReviewCreatedEvent < Event
  def process!
    dto = Builders::DecisionReviewCreatedDtoBuilder.new(self)
    response = ExternalApi::CaseflowService.establish_decision_review_created_records_from_event!(dto)

    Rails.logger.info("Received #{response.code}")

    if response.code.to_i == 201
      update!(completed_at: Time.zone.now)
    end
  rescue AppealsConsumer::Error::ClientRequestError => error
    Rails.logger.error(error.message)
    update!(error: error.message)
  rescue StandardError => error
    ExternalApi::CaseflowService.establish_decision_review_created_event_error!(
      id,
      JSON.parse(message_payload)["claim_id"],
      error.message
    )
    Rails.logger.error(error.message)
  end
end
