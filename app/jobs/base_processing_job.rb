# frozen_string_literal: true

# This is the base processing job class
class BaseProcessingJob < ApplicationJob
  private

  def init_setup(event)
    @event = event
    set_current_user_to_system_admin
  end

  def start_processing!
    ActiveRecord::Base.transaction do
      @event.in_progress!
      @event_audit = EventAudit.create(id: @event.id)
    end
  end

  def complete_processing!
    ActiveRecord::Base.transaction do
      @event.processed!
      @event_audit.completed!
    end
  end

  def handle_job_error!(error)
    ActiveRecord::Base.transaction do
      @event.handle_failure!
      @event_audit.failed!(error.message)
    end
  end

  def set_current_user_to_system_admin
    RequestStore.store[:current_user] = {
      css_id: "system_admin_css_id",
      station_id: "system_admin_station_id"
    }
  end
end