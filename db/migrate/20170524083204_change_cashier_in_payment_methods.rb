class ChangeCashierInPaymentMethods < ActiveRecord::Migration
  def change
    change_column :payment_methods, :cashier, :boolean, null: false, default: false
  end
end
