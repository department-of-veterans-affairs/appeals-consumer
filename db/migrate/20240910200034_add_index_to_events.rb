class AddIndexToEvents < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :events, :claim_id, algorithm: :concurrently
    add_index :events, :state, algorithm: :concurrently
  end
end
