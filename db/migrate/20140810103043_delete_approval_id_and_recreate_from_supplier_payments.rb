class DeleteApprovalIdAndRecreateFromSupplierPayments < ActiveRecord::Migration
  def change
    remove_index :supplier_payments, :supplier_invoice_approval__id    
    remove_column :supplier_payments, :supplier_invoice_approval__id

    add_column :supplier_payments, :supplier_invoice_approval_id, :integer
    add_index :supplier_payments, :supplier_invoice_approval_id
  end
end
