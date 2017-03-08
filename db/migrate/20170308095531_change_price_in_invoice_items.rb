class ChangePriceInInvoiceItems < ActiveRecord::Migration
  def change
    change_column :invoice_items, :price, :decimal, precision: 12, scale: 6, null: false, default: '0'
    change_column :invoice_items, :discount, :decimal, precision: 12, scale: 6, null: false, default: '0'
  end
end
