class AddSepaReturnCodeToClientPayments < ActiveRecord::Migration
  def change
    add_column :client_payments, :sepa_return_code_id, :integer
    add_index :client_payments, :sepa_return_code_id
  end
end
