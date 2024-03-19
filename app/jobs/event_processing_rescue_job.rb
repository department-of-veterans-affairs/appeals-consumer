# frozen_string_literal: true

class EventProcessingRescueJob < ApplicationJob
  def perform
    start_time = Time.zone.now
    stuck_audits = EventAudit.stuck
    stuck_audits.find_each do |audit|
      break if time_exceeded?(start_time)

      audit.cancelled!
      audit.ended_at!

      Rails.logger.info("EventAudit with id: #{audit.id} was cancelled")

      handle_reenqueue(audit.event)
    end
  end

  private

  def time_exceeded?(start_time)
    Time.zone.now - start_time > 25.minutes
  end

  def handle_reenqueue(event)
    unless event.end_state?
      job_class = event.determine_job_for
      if job_class
        job_class.perform_later(event)
        Rails.logger.info(
          "Event with id: #{event.id} was found to be not \"PROCESSED\" and was re-enqueued into a new processing job"
        )
      else
        rails.logger.error("Failed to re-enqueue job for Event ID: #{event.id}")
      end
    end
  end
end
