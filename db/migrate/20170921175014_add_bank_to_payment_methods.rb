class AddBankToPaymentMethods < ActiveRecord::Migration
  def change
    add_column :payment_methods, :bank, :boolean, null: false, default: false
  end
end
