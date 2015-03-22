class AddPaymentMethodToClients < ActiveRecord::Migration
  def change
    add_column :clients, :payment_method_id, :integer
    add_index :clients, :payment_method_id
  end
end
