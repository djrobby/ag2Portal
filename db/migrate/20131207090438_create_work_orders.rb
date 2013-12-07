class CreateWorkOrders < ActiveRecord::Migration
  def change
    create_table :work_orders do |t|
      t.string :order_no
      t.references :work_order_type
      t.references :work_order_status
      t.references :work_order_labor
      t.timestamp :started_at
      t.timestamp :completed_at
      t.timestamp :closed_at
      t.references :charge_account
      t.references :project
      t.references :area
      t.references :store

      t.timestamps
    end
    add_index :work_orders, :work_order_type_id
    add_index :work_orders, :work_order_status_id
    add_index :work_orders, :work_order_labor_id
    add_index :work_orders, :charge_account_id
    add_index :work_orders, :project_id
    add_index :work_orders, :area_id
    add_index :work_orders, :store_id
  end
end
