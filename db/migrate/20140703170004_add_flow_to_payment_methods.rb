class AddFlowToPaymentMethods < ActiveRecord::Migration
  def change
    add_column :payment_methods, :flow, :integer, :limit => 2
    add_index :payment_methods, :flow
  end
end
