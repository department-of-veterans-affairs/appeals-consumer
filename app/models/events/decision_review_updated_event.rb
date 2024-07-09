# frozen_string_literal: true

# A subclass of Event, representing the DecisionReviewUpdated Kafka topic event.
class Events::DecisionReviewUpdatedEvent < Event
  def process!; end
end
