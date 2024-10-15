# frozen_string_literal: true

class DecisionReviewCompletedEventProcessingJob < BaseEventProcessingJob
  queue_as :low_priority
end
