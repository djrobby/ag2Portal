class CreateSupplierPayments < ActiveRecord::Migration
  def change
    create_table :supplier_payments do |t|
      t.references :supplier
      t.references :supplier_invoice
      t.references :payment_method
      t.date :payment_date
      t.decimal :amount, :precision => 13, :scale => 4, :null => false, :default => '0'
      t.string :remarks
      t.references :approver

      t.timestamps
    end
    add_index :supplier_payments, :supplier_id
    add_index :supplier_payments, :supplier_invoice_id
    add_index :supplier_payments, :payment_method_id
    add_index :supplier_payments, :approver_id
  end
end
