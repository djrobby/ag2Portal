class AddNoToSupplierPayment < ActiveRecord::Migration
  def change
    add_column :supplier_payments, :payment_no, :string

    add_index :supplier_payments, :payment_no
  end
end
