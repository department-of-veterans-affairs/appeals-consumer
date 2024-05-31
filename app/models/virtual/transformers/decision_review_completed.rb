# frozen_string_literal: true

# DecisionReviewCompleted represents the message_payload from an individual DecisionReviewCompletedEvent
class Transformers::DecisionReviewCompleted
  include MessagePayloadValidator

  attr_accessor :event_id

  def initialize(event_id, message_payload = {})
    @event_id = event_id
    validate(message_payload, self.class.name)
    assign(message_payload)
  end

  

end