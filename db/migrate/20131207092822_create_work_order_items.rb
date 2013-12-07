class CreateWorkOrderItems < ActiveRecord::Migration
  def change
    create_table :work_order_items do |t|
      t.references :work_order
      t.references :product
      t.string :description
      t.decimal :quantity, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.decimal :cost, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.decimal :price, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.references :tax_type
      t.references :store

      t.timestamps
    end
    add_index :work_order_items, :work_order_id
    add_index :work_order_items, :product_id
    add_index :work_order_items, :tax_type_id
    add_index :work_order_items, :store_id
    add_index :work_order_items, :description
  end
end
