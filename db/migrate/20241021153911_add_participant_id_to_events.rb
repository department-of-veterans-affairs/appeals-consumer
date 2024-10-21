class AddParticipantIdToEvents < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    add_column :events, :participant_id, :integer, comment: "Participant ID associated with People Updated Events"
    add_index :events, :participant_id, algorithm: :concurrently
  end

  def down
    remove_column :events, :participant_id, :integer, comment: "Participant ID associated with People Updated Events"
    remove_index :events, :participant_id, algorithm: :concurrently
  end
end
