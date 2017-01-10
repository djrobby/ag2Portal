class AddTariffTypeIdToWaterSupplyContract < ActiveRecord::Migration
  def change
    add_column :water_supply_contracts, :tariff_type_id, :integer

    add_index :water_supply_contracts, :tariff_type_id
  end
end
