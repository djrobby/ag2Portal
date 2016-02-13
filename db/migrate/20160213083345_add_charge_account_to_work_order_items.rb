class AddChargeAccountToWorkOrderItems < ActiveRecord::Migration
  def change
    add_column :work_order_items, :charge_account_id, :integer
    add_column :work_order_workers, :charge_account_id, :integer
    add_column :work_order_tools, :charge_account_id, :integer
    add_column :work_order_vehicles, :charge_account_id, :integer
    add_column :work_order_subcontractors, :charge_account_id, :integer

    add_index :work_order_items, :charge_account_id
    add_index :work_order_workers, :charge_account_id
    add_index :work_order_tools, :charge_account_id
    add_index :work_order_vehicles, :charge_account_id
    add_index :work_order_subcontractors, :charge_account_id
  end
end
