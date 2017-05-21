class AddCashierToPaymentMethods < ActiveRecord::Migration
  def change
    add_column :payment_methods, :cashier, :boolean
  end
end
