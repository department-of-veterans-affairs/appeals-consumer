# frozen_string_literal: true

class EventProcessingRescueJob < ApplicationJob
  rescue_from(StandardError) do |error|
    log_error("encountered an exception: #{error.message}")
  end

  def perform
    start_time = Time.zone.now
    stuck_audits = EventAudit.stuck
    stuck_audits.find_each do |audit|
      if time_exceeded?(start_time)
        log_info("Time limit exceeded, stopping job execution.")
        break
      end

      process_audit(audit)
    end
  end

  private

  def time_exceeded?(start_time)
    Time.zone.now - start_time > 25.minutes
  end

  def process_audit(audit)
    ActiveRecord::Base.transaction do
      audit.cancelled!
      audit.ended_at!
    end

    log_info("EventAudit with id: #{audit.id} was cancelled")

    handle_reenqueue(audit.event)
  rescue StandardError => error
    log_error("Failed to process audit #{audit.id}: #{error.message}")
  end

  def handle_reenqueue(event)
    return if event.end_state?

    job_class = event.determine_job
    if job_class
      job_class.perform_later(event)
      log_info(
        "Event with id: #{event.id} was found to be not \"PROCESSED\" and was re-enqueued into a new processing job"
      )
    else
      log_error("Failed to re-enqueue job for Event ID: #{event.id}")
    end
  rescue StandardError => error
    log_error("Error during the re-enqueue for event #{event.id}: #{error.message}")
  end

  def log_info(message)
    Rails.logger.info("[EventProcessingRescueJob] #{message}")
  end

  def log_error(message)
    Rails.logger.error("[EventProcessingRescueJob] #{message}")
    # TODO: notify sentry and slack
  end
end
