class AddPressureToWaterSupplyContracts < ActiveRecord::Migration
  def change
    add_column :water_supply_contracts, :max_pressure, :string
    add_column :water_supply_contracts, :min_pressure, :string
    add_column :water_supply_contracts, :contract_term, :string
  end
end
