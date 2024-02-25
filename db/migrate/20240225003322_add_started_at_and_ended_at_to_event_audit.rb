class AddStartedAtAndEndedAtToEventAudit < ActiveRecord::Migration[7.1]
  def change
    add_column :event_audits, :started_at, :timestamp, comment: "The time that the event_audit started processing."
    add_column :event_audits, :ended_at, :timestamp, comment: "The time that the event_audit finished processing."
  end
end
