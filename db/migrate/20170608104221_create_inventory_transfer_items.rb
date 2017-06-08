class CreateInventoryTransferItems < ActiveRecord::Migration
  def change
    create_table :inventory_transfer_items do |t|
      t.references :inventory_transfer
      t.references :product
      t.decimal :quantity, :decimal, :precision => 12, :scale => 4, :null => false, :default => 0
      t.decimal :outbound_current, :decimal, :precision => 12, :scale => 4, :null => false, :default => 0
      t.decimal :inbound_current, :decimal, :precision => 12, :scale => 4, :null => false, :default => 0
      t.decimal :price, :decimal, :precision => 12, :scale => 4, :null => false, :default => 0
      t.decimal :average_price, :decimal, :precision => 12, :scale => 4, :null => false, :default => 0

      t.timestamps
    end
    add_index :inventory_transfer_items, :inventory_transfer_id
    add_index :inventory_transfer_items, :product_id
  end
end
