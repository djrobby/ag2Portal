class AddFlowToWaterConnectionContractItemTypes < ActiveRecord::Migration
  def change
    add_column :water_connection_contract_item_types, :flow, :integer, limit: 2, null: false, default: 0
  end
end
