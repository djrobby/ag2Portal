class AddCreatedByToServicePointLocations < ActiveRecord::Migration
  def change
    add_column :service_point_locations, :created_by, :integer
    add_column :service_point_locations, :updated_by, :integer
  end
end
