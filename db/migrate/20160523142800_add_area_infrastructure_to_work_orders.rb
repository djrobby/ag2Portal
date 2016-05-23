class AddAreaInfrastructureToWorkOrders < ActiveRecord::Migration
  def change
    add_column :work_orders, :work_order_area_id, :integer
    add_column :work_orders, :infrastructure_id, :integer

    add_index :work_orders, :work_order_area_id
    add_index :work_orders, :infrastructure_id
  end
end
