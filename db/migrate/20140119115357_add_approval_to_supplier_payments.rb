class AddApprovalToSupplierPayments < ActiveRecord::Migration
  def change
    add_column :supplier_payments, :supplier_invoice_approval__id, :integer

    add_index :supplier_payments, :supplier_invoice_approval__id
  end
end
