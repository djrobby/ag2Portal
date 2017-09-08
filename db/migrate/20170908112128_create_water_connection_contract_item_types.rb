class CreateWaterConnectionContractItemTypes < ActiveRecord::Migration
  def change
    create_table :water_connection_contract_item_types do |t|
      t.string :description
      t.decimal :price, :precision => 12, :scale => 4, :null => false, :default => 0

      t.timestamps
    end
  end
end
