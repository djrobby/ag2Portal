class AddUniqueIndexCodeOrganizationToSupplierInvoices < ActiveRecord::Migration
  def change
    add_index :supplier_invoices, :organization_id    
    add_index :supplier_invoices, [:organization_id, :supplier_id, :invoice_no], unique: true, name: 'index_supplier_invoices_on_organization_and_supplier_and_no'
  end
end
