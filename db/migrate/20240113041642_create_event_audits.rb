class CreateEventAudits < ActiveRecord::Migration[7.1]
  def change
    create_table :event_audits, comment: "This table stores a record of each time event processing is attempted." do |t|
      t.belongs_to :event, null: false, foreign_key: true, comment: "Id of the Event that created or updated this record."
      t.string "status", null: false, default: "NOT_STARTED", comment: "A status to indicate what state the record is in such as NOT_STARTED, IN_PROGRESS, PROCESSED, ERROR, FAILED."
      t.text "error", comment: "Error message captured when an event fails to create or update records within Caseflow." 
      t.timestamps null: false, comment: "Automatic timestamp when row was created and when record changes."
    end
  end
end
