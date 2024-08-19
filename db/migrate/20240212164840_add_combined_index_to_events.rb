class AddCombinedIndexToEvents < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :events, [:offset, :partition, :type], algorithm: :concurrently, unique: true
  end
end
