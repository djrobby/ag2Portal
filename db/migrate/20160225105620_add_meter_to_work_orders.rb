class AddMeterToWorkOrders < ActiveRecord::Migration
  def change
    add_column :work_orders, :meter_id, :integer
    add_column :work_orders, :meter_code, :string
    add_column :work_orders, :meter_model_id, :integer
    add_column :work_orders, :caliber_id, :integer
    add_column :work_orders, :meter_owner_id, :integer
    add_column :work_orders, :meter_location_id, :integer
    add_column :work_orders, :last_reading_id, :integer
    add_column :work_orders, :current_reading_date, :timestamp
    add_column :work_orders, :current_reading_index, :integer

    add_index :work_orders, :meter_id
    add_index :work_orders, :meter_code
    add_index :work_orders, :meter_model_id
    add_index :work_orders, :caliber_id
    add_index :work_orders, :meter_owner_id
    add_index :work_orders, :meter_location_id
    add_index :work_orders, :last_reading_id
  end
end
