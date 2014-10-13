class AddCreatedByToWorkOrderVehicles < ActiveRecord::Migration
  def change
    add_column :work_order_vehicles, :created_by, :integer
    add_column :work_order_vehicles, :updated_by, :integer
  end
end
