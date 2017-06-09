class AddUniqueIndexToTaxTypeLedgerAccounts < ActiveRecord::Migration
  def change
    add_index :tax_type_ledger_accounts,
              [:tax_type_id, :input_ledger_account_id, :output_ledger_account_id],
              unique: true, name: 'index_tax_type_ledger_accounts_unique'
  end
end
