class CreateServicePoints < ActiveRecord::Migration
  def change
    create_table :service_points do |t|
      t.string :code
      t.string :name
      t.references :service_point_type
      t.references :service_point_location
      t.references :service_point_purpose
      t.references :water_connection
      t.references :organization
      t.references :company
      t.references :office
      t.string :cadastral_reference
      t.string :gis_id
      t.references :street_directory
      t.string :street_number
      t.string :building
      t.string :floor
      t.string :floor_office
      t.references :zipcode
      t.integer :diameter
      t.boolean :verified
      t.boolean :available_for_contract
      t.references :reading_route
      t.integer :reading_sequence
      t.string :reading_variant

      t.timestamps
    end
    add_index :service_points, :service_point_type_id
    add_index :service_points, :service_point_location_id
    add_index :service_points, :service_point_purpose_id
    add_index :service_points, :water_connection_id
    add_index :service_points, :organization_id
    add_index :service_points, :company_id
    add_index :service_points, :office_id
    add_index :service_points, :street_directory_id
    add_index :service_points, :zipcode_id
    add_index :service_points, :reading_route_id
  end
end
