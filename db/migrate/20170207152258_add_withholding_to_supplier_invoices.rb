class AddWithholdingToSupplierInvoices < ActiveRecord::Migration
  def change
    add_column :supplier_invoices, :withholding, :decimal, :precision => 13, :scale => 4, :null => false, :default => '0'
    add_column :supplier_invoices, :internal_no, :string

    add_index :supplier_invoices, :internal_no
    add_index :supplier_invoices,
              [:project_id, :internal_no],
              unique: true, name: 'index_supplier_invoices_on_project_and_internal_no'
  end
end
