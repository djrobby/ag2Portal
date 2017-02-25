class AddPurchaseOrderToSupplierInvoiceItems < ActiveRecord::Migration
  def change
    add_column :supplier_invoice_items, :purchase_order_id, :integer
    add_column :supplier_invoice_items, :purchase_order_item_id, :integer

    add_index :supplier_invoice_items, :purchase_order_id
    add_index :supplier_invoice_items, :purchase_order_item_id
  end
end
