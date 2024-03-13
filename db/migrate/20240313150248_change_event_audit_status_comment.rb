class ChangeEventAuditStatusComment < ActiveRecord::Migration[7.1]
  def change
    change_column_comment :event_audits, :status, from: "A status to indicate what state the record is in such as IN_PROGRESS, COMPLETED, FAILED.", to: "A status to indicate what state the record is in such as IN_PROGRESS, COMPLETED, FAILED, CANCELLED."
  end
end
