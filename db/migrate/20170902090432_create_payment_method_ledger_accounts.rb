class CreatePaymentMethodLedgerAccounts < ActiveRecord::Migration
  def change
    create_table :payment_method_ledger_accounts do |t|
      t.references :payment_method
      t.references :input_ledger_account
      t.references :output_ledger_account
      t.references :company

      t.timestamps
    end
    add_index :payment_method_ledger_accounts, :payment_method_id
    add_index :payment_method_ledger_accounts, :input_ledger_account_id
    add_index :payment_method_ledger_accounts, :output_ledger_account_id
    add_index :payment_method_ledger_accounts, :company_id
    add_index :payment_method_ledger_accounts,
              [:payment_method_id, :input_ledger_account_id, :output_ledger_account_id],
              unique: true, name: 'index_payment_method_ledger_accounts_unique'
  end
end
