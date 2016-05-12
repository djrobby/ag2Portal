class AddUniqueIndexToInventoryMovements < ActiveRecord::Migration
  def change
    add_index :inventory_movements,
              [:store_id, :product_id, :type, :parent_id, :item_id],
              unique: true, name: 'index_inventory_movements_unique'
  end
end
