class CreateContractedTariffs < ActiveRecord::Migration
  def change
    create_table :contracted_tariffs do |t|
      t.references :water_supply_contract
      t.references :tariff

      t.timestamps
    end
    add_index :contracted_tariffs, :water_supply_contract_id
    add_index :contracted_tariffs, :tariff_id
  end
end
