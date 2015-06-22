class CreateInventoryCountItems < ActiveRecord::Migration
  def change
    create_table :inventory_count_items do |t|
      t.references :inventory_count
      t.references :product
      t.decimal :quantity, :precision => 12, :scale => 4, :null => false, :default => '0'

      t.timestamps
    end
    add_index :inventory_count_items, :inventory_count_id
    add_index :inventory_count_items, :product_id
  end
end
