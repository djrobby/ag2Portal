class AddPaymentMethodToSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :payment_method_id, :integer
    add_column :suppliers, :ledger_account, :string
    add_column :suppliers, :discount_rate, :decimal, :precision => 12, :scale => 4, :null => false, :default => '0'
    add_column :suppliers, :active, :boolean
    add_column :suppliers, :max_orders_count, :integer
    add_column :suppliers, :max_orders_sum, :decimal, :precision => 12, :scale => 4, :null => false, :default => '0'
    add_column :suppliers, :contract_number, :string
    add_column :suppliers, :remarks, :string

    add_index :suppliers, :payment_method_id
    add_index :suppliers, :ledger_account
    add_index :suppliers, :contract_number
  end
end
