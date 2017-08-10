class AddReturnPaymentMethodToPaymentTypes < ActiveRecord::Migration
  def change
    add_column :payment_types, :return_payment_method_id, :integer
    add_index :payment_types, :return_payment_method_id
  end
end
