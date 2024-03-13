# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_03_13_150248) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "event_audits", comment: "This table stores a record of each time event processing is attempted.", force: :cascade do |t|
    t.bigint "event_id", null: false, comment: "Id of the Event that created or updated this record."
    t.string "status", default: "IN_PROGRESS", null: false, comment: "A status to indicate what state the record is in such as IN_PROGRESS, COMPLETED, FAILED, CANCELLED."
    t.text "error", comment: "Error message captured when an event fails to create or update records within Caseflow."
    t.datetime "created_at", null: false, comment: "Automatic timestamp when row was created and when record changes."
    t.datetime "updated_at", null: false, comment: "Automatic timestamp when row was created and when record changes."
    t.datetime "started_at", precision: nil, comment: "The time that the event_audit starts processing an event"
    t.datetime "ended_at", precision: nil, comment: "The time that the event_audit finishes processing an event"
    t.index ["event_id"], name: "index_event_audits_on_event_id"
  end

  create_table "events", comment: "This table stores events that are consumed from Kafka Topics.", force: :cascade do |t|
    t.string "type", null: false, comment: "Type of Event being consumed"
    t.jsonb "message_payload", null: false, comment: "JSON payload received from Kafka Topic"
    t.datetime "completed_at", comment: "Timestamp of when event was successfully completed."
    t.text "error", comment: "Error message captured when there is a problem parsing through message_payload attributes."
    t.datetime "created_at", null: false, comment: "Automatic timestamp when row was created and when record changes."
    t.datetime "updated_at", null: false, comment: "Automatic timestamp when row was created and when record changes."
    t.string "state", default: "NOT_STARTED", null: false, comment: "A status to indicate what state the record is in such as NOT_STARTED, IN_PROGRESS, PROCESSED, ERROR, FAILED."
    t.integer "partition", null: false
    t.integer "offset", null: false
    t.index ["offset", "partition", "type"], name: "index_events_on_offset_and_partition_and_type", unique: true
    t.index ["type"], name: "index_events_on_type"
  end

  add_foreign_key "event_audits", "events"
end
