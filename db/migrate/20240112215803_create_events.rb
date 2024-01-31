class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events, comment: "This table stores events that are consumed from Kafka Topics." do |t|
      t.string "type", null: false, comment: "Type of Event being consumed"
      t.jsonb "message_payload", null: false, comment: "JSON payload received from Kafka Topic"
      t.datetime "completed_at", comment: "Timestamp of when event was successfully completed."
      t.text "error", comment: "Error message captured when there is a problem parsing through message_payload attributes."
      t.timestamps null: false, comment: "Automatic timestamp when row was created and when record changes."
    end
  end
end
