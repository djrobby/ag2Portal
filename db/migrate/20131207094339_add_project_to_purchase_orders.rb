class AddProjectToPurchaseOrders < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :project_id, :integer
    add_column :purchase_orders, :store_id, :integer
    add_column :purchase_orders, :work_order_id, :integer
    add_column :purchase_orders, :charge_account_id, :integer
    add_column :purchase_orders, :retention_pct, :decimal, :precision => 6, :scale => 2, :null => false, :default => '0'
    add_column :purchase_orders, :retention_time, :integer

    add_index :purchase_orders, :project_id
    add_index :purchase_orders, :store_id
    add_index :purchase_orders, :work_order_id
    add_index :purchase_orders, :charge_account_id
  end
end
