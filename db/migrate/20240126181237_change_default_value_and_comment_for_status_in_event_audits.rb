class ChangeDefaultValueAndCommentForStatusInEventAudits < ActiveRecord::Migration[7.1]
  def change
    change_column_default :event_audits, :status, from: "NOT_STARTED", to: "IN_PROGRESS"
    change_column_comment :event_audits, :status, "A status to indicate what state the record is in such as IN_PROGRESS, COMPLETED, FAILED."
  end
end
