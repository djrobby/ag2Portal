class AddPubRecordToWaterSupplyContracts < ActiveRecord::Migration
  def change
    add_column :water_supply_contracts, :pub_record, :string
  end
end