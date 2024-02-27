# frozen_string_literal: true

class BaseProcessingJob < ApplicationJob
  queue_as :high_priority

  def perform(event)
    init_setup(event)
    start_processing!
    event.process!
    complete_processing!

  rescue StandardError => error

    # transaction do
    #   @event_audit.failed!(error.message) # ea.update(error: error.message, status: "FAILED")
    #   @event.handle_failure!
    #   #event.failed? ? event.failed! : event.error! # event.update(state: "FAILED") : event:update(state: "ERROR")
    # end

    Rails.logger.error(error)
  end

  def start_processing! 
    transaction do
      @event.in_progress! # event.update(state: "IN_PROGRESS")
      @event_audit = EventAudit.create(event: @event)
    end
  end

  def complete_processing!
    transaction do
      @event_audit.completed! # ea.update(status: "COMPLETED")
      @event.processed!# event.update(state: "PROCESSED")
    end
  end

  def handle_job_error!(error)
    transaction do
      @event_audit.failed!(error.message) # ea.update(error: error.message, status: "FAILED")
      @event.handle_failure!
      #event.failed? ? event.failed! : event.error! # event.update(state: "FAILED") : event:update(state: "ERROR")
    end

    Rails.logger.error(error)
  end

  def init_setup(event)
    RequestStore.store[:current_user] = {
      css_id: ENV["CSS_ID"],
      station_id: ENV["STATION_ID"]
    }
    @event = event
  end
end
