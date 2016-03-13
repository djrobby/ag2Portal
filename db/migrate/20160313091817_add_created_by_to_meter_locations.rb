class AddCreatedByToMeterLocations < ActiveRecord::Migration
  def change
    add_column :meter_locations, :created_by, :integer
    add_column :meter_locations, :updated_by, :integer
  end
end
