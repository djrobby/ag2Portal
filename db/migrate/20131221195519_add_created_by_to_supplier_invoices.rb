class AddCreatedByToSupplierInvoices < ActiveRecord::Migration
  def change
    add_column :supplier_invoices, :created_by, :integer
    add_column :supplier_invoices, :updated_by, :integer
  end
end
