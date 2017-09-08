class AddCreatedByToWaterConnectionContractItemTypes < ActiveRecord::Migration
  def change
    add_column :water_connection_contract_item_types, :created_by, :integer
    add_column :water_connection_contract_item_types, :updated_by, :integer
  end
end
