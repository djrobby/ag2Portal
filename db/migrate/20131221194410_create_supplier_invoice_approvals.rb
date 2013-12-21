class CreateSupplierInvoiceApprovals < ActiveRecord::Migration
  def change
    create_table :supplier_invoice_approvals do |t|
      t.references :supplier_invoice
      t.timestamp :approval_date
      t.decimal :approved_amount, :precision => 13, :scale => 4, :null => false, :default => '0'
      t.references :approver
      t.string :remarks

      t.timestamps
    end
    add_index :supplier_invoice_approvals, :supplier_invoice_id
    add_index :supplier_invoice_approvals, :approver_id
    add_index :supplier_invoice_approvals, :approval_date
  end
end
