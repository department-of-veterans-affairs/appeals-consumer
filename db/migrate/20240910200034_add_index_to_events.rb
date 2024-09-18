class AddIndexToEvents < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    add_index :events, :claim_id, algorithm: :concurrently
    add_index :events, :completed_at, algorithm: :concurrently
    add_index :events, :state, algorithm: :concurrently
  end

  def down
    remove_index :events, :claim_id, algorithm: :concurrently
    remove_index :events, :completed_at, algorithm: :concurrently
    remove_index :events, :state, algorithm: :concurrently
  end
end
