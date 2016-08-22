class AddCreatedByToWaterSupplyContracts < ActiveRecord::Migration
  def change
    add_column :water_supply_contracts, :created_by, :integer
    add_column :water_supply_contracts, :updated_by, :integer
  end
end
