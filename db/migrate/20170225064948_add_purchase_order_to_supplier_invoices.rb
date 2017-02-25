class AddPurchaseOrderToSupplierInvoices < ActiveRecord::Migration
  def change
    add_column :supplier_invoices, :purchase_order_id, :integer

    add_index :supplier_invoices, :purchase_order_id
  end
end
