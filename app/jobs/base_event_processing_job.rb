# frozen_string_literal: true

# This is the base processing job class
class BaseEventProcessingJob < ApplicationJob
  queue_as :high_priority

  def perform(event)
    init_setup(event)
    start_processing!
    @event.process!
    complete_processing!
  rescue StandardError => error
    handle_job_error!(error)
  ensure
    ended_at
  end

  private

  def ended_at
    @event_audit.update!(ended_at: Time.zone.now)
  end

  def init_setup(event)
    @event = event
    set_current_user_to_system_admin
  end

  def start_processing!
    ActiveRecord::Base.transaction do
      @event.in_progress!
      @event_audit = EventAudit.create(event: @event)
      @event_audit.started_at!
    end
  end

  def complete_processing!
    ActiveRecord::Base.transaction do
      @event.processed!
      @event_audit.completed!
    end
  end

  def handle_job_error!(error)
    log_error
    ActiveRecord::Base.transaction do
      @event.handle_failure(error.message)
      @event_audit.failed!(error.message)
    end
  end

  def set_current_user_to_system_admin
    RequestStore.store[:current_user] = {
      css_id: ENV["CSS_ID"],
      station_id: ENV["STATION_ID"]
    }
  end

  def log_error
    msg = "[#{self.class.name}] An error has occured while processing a job for the event with event_id: #{@event.id}."
    msg += " Please check EventAudit with id: #{@event_audit.id} for details." if @event_audit
    Rails.logger.error(msg)
  end
end