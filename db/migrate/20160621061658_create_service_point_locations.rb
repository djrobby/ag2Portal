class CreateServicePointLocations < ActiveRecord::Migration
  def change
    create_table :service_point_locations do |t|
      t.string :name

      t.timestamps
    end
  end
end
