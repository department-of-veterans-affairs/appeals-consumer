class AddClaimIdToEvent < ActiveRecord::Migration[7.1]
  def up
    add_column :events, :claim_id, :integer, comment: "Claim ID associated with Decision Review Events"
  end

  def down
    remove_column :events, :claim_id, :integer, comment: "Claim ID associated with Decision Review Events"
  end
end
