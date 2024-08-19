class AddNotesToEventAudits < ActiveRecord::Migration[7.1]
  def change
    add_column :event_audits, :notes, :string, comment: "Notes containing relevant information about event processing."
  end
end
