class AddApproverToInventoryCounts < ActiveRecord::Migration
  def change
    remove_column :inventory_counts, :confirmed

    add_column :inventory_counts, :approver_id, :integer
    add_column :inventory_counts, :approval_date, :timestamp
    add_index :inventory_counts, :approver_id
  end
end
