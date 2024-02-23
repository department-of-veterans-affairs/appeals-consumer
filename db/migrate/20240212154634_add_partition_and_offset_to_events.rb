class AddPartitionAndOffsetToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :partition, :integer, null: false
    add_column :events, :offset, :integer, null: false
  end
end
