class CreatePurchaseOrderItems < ActiveRecord::Migration
  def change
    create_table :purchase_order_items do |t|
      t.references :purchase_order
      t.references :product
      t.string :code
      t.string :description
      t.decimal :quantity, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.decimal :price, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.decimal :discount_pct, :precision => 6, :scale => 2, :null => false, :default => '0'
      t.decimal :discount, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.references :tax_type
      t.date :delivery_date

      t.timestamps
    end
    add_index :purchase_order_items, :purchase_order_id
    add_index :purchase_order_items, :product_id
    add_index :purchase_order_items, :tax_type_id
    add_index :purchase_order_items, :code
    add_index :purchase_order_items, :description
    add_index :purchase_order_items, :delivery_date
  end
end
