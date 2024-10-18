# frozen_string_literal: true

class DecisionReviewCompletedEventProcessingJob < BaseEventProcessingJob
  queue_as :high_priority
end
