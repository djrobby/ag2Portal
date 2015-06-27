class AddStocksToInventoryCountItems < ActiveRecord::Migration
  def change
    add_column :inventory_count_items, :initial, :decimal, :precision => 12, :scale => 4, :null => false, :default => '0'
    add_column :inventory_count_items, :current, :decimal, :precision => 12, :scale => 4, :null => false, :default => '0'
  end
end
