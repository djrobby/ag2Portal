class AddLatLonToReadings < ActiveRecord::Migration
  def change
    add_column :readings, :lat, :decimal
    add_column :readings, :lng, :decimal

    add_column :pre_readings, :lat, :decimal
    add_column :pre_readings, :lng, :decimal
  end
end
