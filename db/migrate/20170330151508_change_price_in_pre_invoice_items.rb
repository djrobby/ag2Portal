class ChangePriceInPreInvoiceItems < ActiveRecord::Migration
  def change
    change_column :pre_invoice_items, :price, :decimal, precision: 12, scale: 6, null: false, default: '0'
    change_column :pre_invoice_items, :discount, :decimal, precision: 12, scale: 6, null: false, default: '0'
  end
end
