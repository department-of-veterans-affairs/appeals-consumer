# frozen_string_literal: true

# A subclass of Event, representing the DecisionReviewUpdated Kafka topic event.
class Events::DecisionReviewUpdatedEvent < Event
  def process!
    if decision_review_event_pending?
      error_message = "Event IDs still needing processing: #{decision_review_events.pluck(:id).join(', ')}"
      fail AppealsConsumer::Error::PreviousDecisionReviewEventsStillPending, error_message
    end

    dto = Builders::DecisionReviewUpdated::DtoBuilder.new(self)
    response = ExternalApi::CaseflowService.edit_records_from_decision_review_updated_event!(dto)

    handle_response(response)
  rescue StandardError => error
    handle_error(error)
    raise error
  end

  def decision_review_event_pending?
    decision_review_events.exists?
  end

  private

  def decision_review_events
    Event.where(claim_id: claim_id)
      .where(state: %w[ERROR FAILED IN_PROGRESS NOT_STARTED])
      .where(completed_at: nil)
      .where(
        "(type = 'Events::DecisionReviewCreatedEvent')  OR
        (type = 'Events::DecisionReviewUpdatedEvent' AND message_payload->>'update_time' < ?)",
        message_payload_hash["update_time"]
      )
  end

  def handle_error(error)
    logger.error(error, { error: error })

    state = (error_count < ENV["MAX_ERRORS_FOR_FAILURE"].to_i) ? "FAILED" : "ERROR"
    update(
      error: error.message,
      state: state
    )

    EventAudit.create!(
      event: self,
      error: error.message,
      status: "FAILED"
    )
  end

  def error_count
    EventAudit.where(event_id: id).count
  end
end
