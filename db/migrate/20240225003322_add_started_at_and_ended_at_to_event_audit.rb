class AddStartedAtAndEndedAtToEventAudit < ActiveRecord::Migration[7.1]
  def change
    add_column :event_audits, :started_at, :timestamp, comment: "The time that the event_audit starts processing an event"
    add_column :event_audits, :ended_at, :timestamp, comment: "The time that the event_audit finishes processing an event"
  end
end
