class AddMeterToServicePoints < ActiveRecord::Migration
  def change
    add_column :service_points, :meter_id, :integer

    add_index :service_points, :meter_id
  end
end
