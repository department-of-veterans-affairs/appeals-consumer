class ChangeCommentsForEventAudits < ActiveRecord::Migration[7.1]
  def change
    change_column_comment :event_audits, :updated_at, "Automatic timestamp when record is created or updated."
    change_column_comment :event_audits, :created_at, "Automatic timestamp when record is created."
    change_column_comment :event_audits, :event_id, "Id of the Event being processed."
    change_column_comment :event_audits, :status, "Indicates current status of event_audit while processing the event such as IN_PROGRESS, COMPLETED, FAILED, CANCELLED."
    change_column_comment :event_audits, :error, "Error message captured when an error occurs during event_audits attempt to process an event."
  end
end
