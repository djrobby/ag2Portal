class AddUseToWaterSupplyContracts < ActiveRecord::Migration
  def change
    add_column :water_supply_contracts, :use_id, :integer

    add_index :water_supply_contracts, :use_id
  end
end
