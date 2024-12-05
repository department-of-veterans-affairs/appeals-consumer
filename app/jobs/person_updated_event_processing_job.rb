# frozen_string_literal: true

class PersonUpdatedEventProcessingJob < BaseEventProcessingJob
  queue_as :low_priority
end
