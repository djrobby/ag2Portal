class CreateDeliveryNoteItems < ActiveRecord::Migration
  def change
    create_table :delivery_note_items do |t|
      t.references :delivery_note
      t.references :sale_offer
      t.references :sale_offer_item
      t.references :product
      t.string :description
      t.decimal :quantity, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.decimal :cost, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.decimal :price, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.decimal :discount_pct, :precision => 6, :scale => 2, :null => false, :default => '0'
      t.decimal :discount, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.references :tax_type
      t.references :store
      t.references :work_order
      t.references :charge_account

      t.timestamps
    end
    add_index :delivery_note_items, :delivery_note_id
    add_index :delivery_note_items, :sale_offer_id
    add_index :delivery_note_items, :sale_offer_item_id
    add_index :delivery_note_items, :product_id
    add_index :delivery_note_items, :tax_type_id
    add_index :delivery_note_items, :store_id
    add_index :delivery_note_items, :work_order_id
    add_index :delivery_note_items, :charge_account_id
    add_index :delivery_note_items, :description
  end
end
