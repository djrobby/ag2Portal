class AddUnsubscribeBillToWaterSupplyContracts < ActiveRecord::Migration
  def change
    add_column :water_supply_contracts, :unsubscribe_bill_id, :integer
    add_column :water_supply_contracts, :bailback_bill_id, :integer

    add_index :water_supply_contracts, :unsubscribe_bill_id
    add_index :water_supply_contracts, :bailback_bill_id
  end
end
