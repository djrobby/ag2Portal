class AddSaleOfferToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :sale_offer_id, :integer
    add_column :invoice_items, :sale_offer_id, :integer
    add_column :invoice_items, :sale_offer_item_id, :integer

    add_index :invoices, :sale_offer_id
    add_index :invoice_items, :sale_offer_id
    add_index :invoice_items, :sale_offer_item_id
  end
end
