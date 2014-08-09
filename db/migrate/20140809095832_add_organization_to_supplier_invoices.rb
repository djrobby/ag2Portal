class AddOrganizationToSupplierInvoices < ActiveRecord::Migration
  def change
    add_column :supplier_invoices, :organization_id, :integer
  end
end
