class CreateWaterConnectionContractItems < ActiveRecord::Migration
  def change
    create_table :water_connection_contract_items do |t|
      t.references :water_connection_contract
      t.references :water_connection_contract_item_type
      t.decimal :quantity, :precision => 12, :scale => 4, :null => false, :default => 0

      t.timestamps
    end
    add_index :water_connection_contract_items, :water_connection_contract_id, name: 'index_water_connection_contract_items_on_contract'
    add_index :water_connection_contract_items, :water_connection_contract_item_type_id, name: 'index_water_connection_contract_items_on_type'
  end
end
