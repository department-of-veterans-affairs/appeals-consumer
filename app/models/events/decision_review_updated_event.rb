# frozen_string_literal: true

# A subclass of Event, representing the DecisionReviewUpdated Kafka topic event.
class Events::DecisionReviewUpdatedEvent < Event
  def process!
    fail AppealsConsumer::Error::PreviousDecisionReviewEventsStillPending if decision_review_event_pending?
  end

  # WIP: This may change, not in love with this solution just yet
  def decision_review_event_pending?
    Events::DecisionReviewCreatedEvent
      .where(claim_id: event.claim_id)
      .where.not(state: "processed")
      .where(completed_at: nil)
      .exists? ||
      Events::DecisionReviewUpdatedEvent
        .where(claim_id: event.claim_id)
        .where("update_time < ?", current_event.update_time)
        .where.not(state: "processed")
        .where(completed_at: nil)
        .exists?
  end
end
