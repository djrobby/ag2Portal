class AddApproverToPurchaseOrders < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :approver_id, :integer
    add_column :purchase_orders, :approval_date, :timestamp
    add_index :purchase_orders, :approver_id
  end
end
