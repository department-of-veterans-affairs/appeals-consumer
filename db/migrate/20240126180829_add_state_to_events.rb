class AddStateToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :state, :string, default: "NOT_STARTED", null: false, comment: "A status to indicate what state the record is in such as NOT_STARTED, IN_PROGRESS, PROCESSED, ERROR, FAILED."
  end
end
