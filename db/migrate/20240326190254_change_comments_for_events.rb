class ChangeCommentsForEvents < ActiveRecord::Migration[7.1]
  def change
    change_column_comment :events, :partition, "Kafka Partition that Message is hosted on."
    change_column_comment :events, :offset, "Kafka Offset associated with Message."
    change_column_comment :events, :updated_at, "Automatic timestamp when record is created or updated."
    change_column_comment :events, :created_at, "Automatic timestamp when record is created."
    change_column_comment :events, :state, "Indicates what state the Event is in such as NOT_STARTED, IN_PROGRESS, PROCESSED, ERROR, FAILED."
    change_column_comment :events, :error, "Most recent Error message captured when event is being consumed or event_audit is being processed."
  end
end
