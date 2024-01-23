# frozen_string_literal: true

class DecisionReviewCreatedJob < ApplicationJob
  queue_as :high_priority

  def perform(event)
    DecisionReviewCreatedEvent.process!(event)
  end
end
