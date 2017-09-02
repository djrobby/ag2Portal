class AddLedgerAccountToPaymentMethods < ActiveRecord::Migration
  def change
    add_column :payment_methods, :input_ledger_account_id, :integer
    add_column :payment_methods, :output_ledger_account_id, :integer

    add_index :payment_methods, :input_ledger_account_id
    add_index :payment_methods, :output_ledger_account_id
  end
end
