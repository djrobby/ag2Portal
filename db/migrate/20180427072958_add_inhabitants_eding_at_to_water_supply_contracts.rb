class AddInhabitantsEdingAtToWaterSupplyContracts < ActiveRecord::Migration
  def change
    add_column :water_supply_contracts, :inhabitants_ending_at, :date
  end
end
