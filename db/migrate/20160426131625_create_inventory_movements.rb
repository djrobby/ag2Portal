class CreateInventoryMovements < ActiveRecord::Migration
  def change
    create_table :inventory_movements do |t|
      t.references :store
      t.references :product
      t.string :type
      t.date :mdate
      t.integer :parent_id
      t.integer :item_id
      t.decimal :quantity, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.decimal :price, :precision => 12, :scale => 4, :null => false, :default => '0'

      t.timestamps
    end
    add_index :inventory_movements, :store_id
    add_index :inventory_movements, :product_id
  end
end
