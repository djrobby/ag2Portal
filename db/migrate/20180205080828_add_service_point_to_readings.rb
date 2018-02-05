class AddServicePointToReadings < ActiveRecord::Migration
  def change
    add_column :pre_readings, :service_point_id, :integer
    add_index :pre_readings, :service_point_id

    add_column :readings, :service_point_id, :integer
    add_index :readings, :service_point_id
  end
end
