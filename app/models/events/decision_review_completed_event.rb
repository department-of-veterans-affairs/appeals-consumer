# frozen_string_literal: true

# A subclass of Event, representing the DecisionReviewCompleted Kafka topic event.
class Events::DecisionReviewCompletedEvent < Event
  def process!; end
end
