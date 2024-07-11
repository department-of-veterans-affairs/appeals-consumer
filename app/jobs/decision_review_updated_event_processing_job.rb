# frozen_string_literal: true

class DecisionReviewUpdatedEventProcessingJob < BaseEventProcessingJob
  queue_as :low_priority
end
