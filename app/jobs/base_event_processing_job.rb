# frozen_string_literal: true

# This is the base processing job class
class BaseEventProcessingJob < ApplicationJob
  include LoggerMixin

  queue_as :high_priority

  def perform(event)
    init_setup(event)

    if @event.end_state?
      logger.info(
        "instance was stopped since the event with "\
        "id: #{@event.id} was already a state of #{@event.state}"
      )
      return true
    end

    MetricsService.record("Processing #{@event}",
                          service: :base_event_processing_job,
                          name: "BaseEventProcessingJob.perform") do
      start_processing!
      @event.process!
      complete_processing!
    end
  rescue StandardError => error
    handle_job_error!(error)
    raise error
  ensure
    ended_at
  end

  private

  def ended_at
    comitted_event_audit&.update(ended_at: Time.zone.now)
  end

  def init_setup(event)
    @event = event
    set_current_user_to_system_admin
  end

  def start_processing!
    ActiveRecord::Base.transaction do
      @event.in_progress!
      @event_audit = EventAudit.create!(event: @event)
      @event_audit.started_at!
    end
  end

  def complete_processing!
    ActiveRecord::Base.transaction do
      @event.processed!
      @event.update!(error: nil)
      @event_audit.completed!
    end
  end

  def handle_job_error!(error)
    log_error
    ActiveRecord::Base.transaction do
      comitted_event_audit&.failed!(error.message)
      @event.handle_failure(error.message)
    end
  end

  def set_current_user_to_system_admin
    RequestStore.store[:current_user] = {
      css_id: ENV["CSS_ID"],
      station_id: ENV["STATION_ID"]
    }
  end

  def log_error
    msg = "An error has occured while processing a job for the event with event_id: #{@event.id}."
    msg += " Please check EventAudit with id: #{@event_audit.id} for details." if comitted_event_audit
    if @event.failed?
      logger.error(msg, { event_id: @event.id }, notify_alerts: true)
    else
      logger.error(msg)
    end
  end

  def comitted_event_audit
    @event_audit unless @event_audit&.new_record?
  end
end
