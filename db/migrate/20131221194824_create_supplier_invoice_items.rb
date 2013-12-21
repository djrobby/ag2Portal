class CreateSupplierInvoiceItems < ActiveRecord::Migration
  def change
    create_table :supplier_invoice_items do |t|
      t.references :supplier_invoice
      t.references :receipt_note
      t.references :receipt_note_item
      t.references :product
      t.string :code
      t.string :description
      t.decimal :quantity, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.decimal :price, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.decimal :discount_pct, :precision => 6, :scale => 2, :null => false, :default => '0'
      t.decimal :discount, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.references :tax_type
      t.references :work_order
      t.references :charge_account

      t.timestamps
    end
    add_index :supplier_invoice_items, :supplier_invoice_id
    add_index :supplier_invoice_items, :receipt_note_id
    add_index :supplier_invoice_items, :receipt_note_item_id
    add_index :supplier_invoice_items, :product_id
    add_index :supplier_invoice_items, :tax_type_id
    add_index :supplier_invoice_items, :work_order_id
    add_index :supplier_invoice_items, :charge_account_id
    add_index :supplier_invoice_items, :code
    add_index :supplier_invoice_items, :description
  end
end
