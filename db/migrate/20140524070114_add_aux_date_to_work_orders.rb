class AddAuxDateToWorkOrders < ActiveRecord::Migration
  def change
    add_column :work_orders, :reported_at, :timestamp
    add_column :work_orders, :approved_at, :timestamp
    add_column :work_orders, :certified_at, :timestamp
    add_column :work_orders, :posted_at, :timestamp
  end
end
