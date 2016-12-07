class AddPaymentMethodToBills < ActiveRecord::Migration
  def change
    add_column :bills, :payment_method_id, :integer
    add_column :invoices, :payment_method_id, :integer

    add_index :bills, :payment_method_id
    add_index :invoices, :payment_method_id
  end
end
