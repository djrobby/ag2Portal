class AddCreatedByToSupplierInvoiceItems < ActiveRecord::Migration
  def change
    add_column :supplier_invoice_items, :created_by, :integer
    add_column :supplier_invoice_items, :updated_by, :integer
  end
end
