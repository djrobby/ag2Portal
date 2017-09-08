class AddCreatedByToWaterConnectionContractItems < ActiveRecord::Migration
  def change
    add_column :water_connection_contract_items, :created_by, :integer
    add_column :water_connection_contract_items, :updated_by, :integer
  end
end
