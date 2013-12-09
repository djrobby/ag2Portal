class AddIndexNoToWorkOrders < ActiveRecord::Migration
  def change
    add_index :work_orders, :order_no
    add_index :work_orders, :started_at
    add_index :work_orders, :completed_at
  end
end
