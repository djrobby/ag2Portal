class AddContractNoToWaterSupplyContracts < ActiveRecord::Migration
  def change
    add_column :water_supply_contracts, :contract_no, :string
    add_index :water_supply_contracts, :contract_no
  end
end
