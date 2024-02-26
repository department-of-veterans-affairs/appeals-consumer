# frozen_string_literal: true

# This is the base event processing job
class BaseEventProcessingJob < BaseProcessingJob
  queue_as :high_priority

  def perform(event)
    @event = event
    # do something
  rescue StandardError => error
    Rails.logger.error(error)
  ensure
    ended_at
  end

  def ended_at
    EventAudit.find_by(event_id: @event.id).update!(ended_at: Time.current)
  end
end
