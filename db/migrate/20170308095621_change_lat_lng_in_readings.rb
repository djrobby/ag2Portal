class ChangeLatLngInReadings < ActiveRecord::Migration
  def change
    change_column :readings, :lat, :decimal, precision: 18, scale: 15
    change_column :readings, :lng, :decimal, precision: 18, scale: 15

    change_column :pre_readings, :lat, :decimal, precision: 18, scale: 15
    change_column :pre_readings, :lng, :decimal, precision: 18, scale: 15
  end
end
