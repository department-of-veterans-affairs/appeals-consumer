# frozen_string_literal: true

class DecisionReviewCreatedEventProcessingJob < ApplicationJob
  queue_as :high_priority

  def perform(event)
    event.process!
  rescue StandardError => error
    Rails.logger.error(error)
  end
end
