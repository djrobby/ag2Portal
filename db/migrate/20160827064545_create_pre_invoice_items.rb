class CreatePreInvoiceItems < ActiveRecord::Migration
  def change
    create_table :pre_invoice_items do |t|
      t.references :pre_invoice
      t.references :tariff
      t.references :product
      t.string :code
      t.string :subcode
      t.string :description
      t.references :measure
      t.decimal :quantity, :precision => 12, :scale => 4, :null => false, :default => '1'
      t.decimal :price, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.decimal :discount_pct, :precision => 6, :scale => 2, :null => false, :default => '0'
      t.decimal :discount, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.references :tax_type

      t.timestamps
    end
    add_index :pre_invoice_items, :pre_invoice_id
    add_index :pre_invoice_items, :tariff_id
    add_index :pre_invoice_items, :product_id
    add_index :pre_invoice_items, :measure_id
    add_index :pre_invoice_items, :tax_type_id
  end
end
