class CreateWaterConnectionContracts < ActiveRecord::Migration
  def change
    create_table :water_connection_contracts do |t|
      t.references :contracting_request
      t.references :water_connection_type
      t.date :contract_date
      t.references :client
      t.references :work_order
      t.references :sale_offer
      t.references :tariff
      t.references :bill
      t.string :remarks

      t.timestamps
    end
    add_index :water_connection_contracts, :contracting_request_id
    add_index :water_connection_contracts, :water_connection_type_id
    add_index :water_connection_contracts, :client_id
    add_index :water_connection_contracts, :work_order_id
    add_index :water_connection_contracts, :sale_offer_id
    add_index :water_connection_contracts, :tariff_id
    add_index :water_connection_contracts, :bill_id
  end
end
