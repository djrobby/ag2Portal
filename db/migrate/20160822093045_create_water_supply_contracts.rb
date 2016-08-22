class CreateWaterSupplyContracts < ActiveRecord::Migration
  def change
    create_table :water_supply_contracts do |t|
      t.references :contracting_request
      t.references :client
      t.references :subscriber
      t.references :reading_route
      t.references :work_order
      t.references :meter
      t.references :tariff_scheme
      t.references :bill
      t.references :caliber
      t.date :contract_date
      t.integer :reading_sequence
      t.string :cadastral_reference
      t.string :gis_id
      t.integer :endowments, :limit => 2, :default => '0'
      t.integer :inhabitants, :limit => 2, :default => '0'
      t.date :installation_date
      t.integer :installation_index
      t.string :remarks
      t.timestamps
    end
    add_index :water_supply_contracts, :contracting_request_id
    add_index :water_supply_contracts, :client_id
    add_index :water_supply_contracts, :subscriber_id
    add_index :water_supply_contracts, :reading_route_id
    add_index :water_supply_contracts, :work_order_id
    add_index :water_supply_contracts, :meter_id
    add_index :water_supply_contracts, :tariff_scheme_id
    add_index :water_supply_contracts, :bill_id
    add_index :water_supply_contracts, :caliber_id
  end
end
