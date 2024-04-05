class ChangeNotesTypeForEventAudits < ActiveRecord::Migration[7.1]
  def change
    change_column :event_audits, :notes, :text
  end
end
