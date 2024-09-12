# frozen_string_literal: true

# A subclass of Event, representing the DecisionReviewUpdated Kafka topic event.
class Events::DecisionReviewUpdatedEvent < Event
  def process!
    dto = Builders::DecisionReviewUpdated::DtoBuilder.new(self)
    response = ExternalApi::CaseflowService.edit_records_from_decision_review_updated_event!(dto)

    handle_response(response)
  rescue StandardError => error
    logger.error(error, { error: error })
    raise error
  end
end
