class CreateMeterLocations < ActiveRecord::Migration
  def change
    create_table :meter_locations do |t|
      t.string :name

      t.timestamps
    end
    add_index :meter_locations, :name
  end
end
