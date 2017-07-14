class AddIndexCompanyToSupplierInvoices < ActiveRecord::Migration
  def change
    add_index :supplier_invoices, :company_id
  end
end
