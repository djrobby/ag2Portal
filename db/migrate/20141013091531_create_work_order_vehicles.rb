class CreateWorkOrderVehicles < ActiveRecord::Migration
  def change
    create_table :work_order_vehicles do |t|
      t.references :work_order
      t.references :vehicle
      t.decimal :distance, :precision => 7, :scale => 2, :null => false, :default => '0'
      t.decimal :cost, :precision => 12, :scale => 4, :null => false, :default => '0'

      t.timestamps
    end
    add_index :work_order_vehicles, :work_order_id
    add_index :work_order_vehicles, :vehicle_id
  end
end
