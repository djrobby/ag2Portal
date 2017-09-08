class AddCaliberToWaterConnectionContracts < ActiveRecord::Migration
  def change
    add_column :water_connection_contracts, :caliber_id, :integer
    add_column :water_connection_contracts, :tariff_type_id, :integer
    add_column :water_connection_contracts, :service_point_purpose_id, :integer
    add_column :water_connection_contracts, :gis_id, :string
    add_column :water_connection_contracts, :cadastral_reference, :string
    add_column :water_connection_contracts, :max_pressure, :string
    add_column :water_connection_contracts, :min_pressure, :string
    add_column :water_connection_contracts, :connections_no, :integer, limit: 2, null: false, default: 1
    add_column :water_connection_contracts, :dwellings_no, :integer, limit: 2, null: false, default: 0
    add_column :water_connection_contracts, :premises_no, :integer, limit: 2, null: false, default: 0
    add_column :water_connection_contracts, :common_items_no, :integer, limit: 2, null: false, default: 0
    add_column :water_connection_contracts, :premises_area, :integer, limit: 3, null: false, default: 0
    add_column :water_connection_contracts, :yard_area, :integer, limit: 3, null: false, default: 0
    add_column :water_connection_contracts, :pipe_length, :decimal, precision: 9, scale: 2, null: false, default: 0

    add_index :water_connection_contracts, :caliber_id
    add_index :water_connection_contracts, :tariff_type_id
    add_index :water_connection_contracts, :service_point_purpose_id
    add_index :water_connection_contracts, :gis_id
    add_index :water_connection_contracts, :cadastral_reference
  end
end
