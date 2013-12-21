class AddCreatedByToSupplierInvoiceApprovals < ActiveRecord::Migration
  def change
    add_column :supplier_invoice_approvals, :created_by, :integer
    add_column :supplier_invoice_approvals, :updated_by, :integer
  end
end
