# frozen_string_literal: true

# A subclass of Event, representing the DecisionReviewUpdated Kafka topic event.
class Events::DecisionReviewUpdatedEvent < Event
  def process!
    if self.message_payload["veteran_participant_id"] == "12345678999" # Number needs to be changed
      fail StandardError, "Testing Error Events::DecisionReviewUpdatedEvent process! error"
    end

    if decision_review_events_pending?
      error_message = "Event IDs still processing: #{pending_decision_review_events.pluck(:id).join(', ')}"
      fail AppealsConsumer::Error::PriorDecisionReviewEventsStillPendingError, error_message
    end

    dto = Builders::DecisionReviewUpdated::DtoBuilder.new(self)
    response = ExternalApi::CaseflowService.edit_records_from_decision_review_updated_event!(dto)

    handle_response(response)
  rescue StandardError => error
    logger.error(error, { error: error })
    raise error
  end

  private

  def decision_review_events_pending?
    pending_decision_review_events.exists?
  end

  def pending_decision_review_events
    Event.where(claim_id: claim_id)
      .where.not(state: "PROCESSED")
      .where(completed_at: nil)
      .where(
        "(type = 'Events::DecisionReviewCreatedEvent')  OR
        (type = 'Events::DecisionReviewUpdatedEvent' AND message_payload ->> 'update_time' < ?)",
        message_payload_hash["update_time"]
      )
  end
end
