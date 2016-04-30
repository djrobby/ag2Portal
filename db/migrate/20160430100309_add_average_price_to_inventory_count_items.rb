class AddAveragePriceToInventoryCountItems < ActiveRecord::Migration
  def change
    add_column :inventory_count_items, :price, :decimal, :precision => 12, :scale => 4, :null => false, :default => '0'
    add_column :inventory_count_items, :average_price, :decimal, :precision => 12, :scale => 4, :null => false, :default => '0'
  end
end
