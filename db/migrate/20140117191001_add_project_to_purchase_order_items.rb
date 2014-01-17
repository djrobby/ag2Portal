class AddProjectToPurchaseOrderItems < ActiveRecord::Migration
  def change
    add_column :purchase_order_items, :project_id, :integer
    add_column :purchase_order_items, :store_id, :integer
    add_column :purchase_order_items, :work_order_id, :integer
    add_column :purchase_order_items, :charge_account_id, :integer

    add_index :purchase_order_items, :project_id
    add_index :purchase_order_items, :store_id
    add_index :purchase_order_items, :work_order_id
    add_index :purchase_order_items, :charge_account_id
  end
end
