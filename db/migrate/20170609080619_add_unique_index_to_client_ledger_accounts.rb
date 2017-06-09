class AddUniqueIndexToClientLedgerAccounts < ActiveRecord::Migration
  def change
    add_index :client_ledger_accounts,
              [:client_id, :ledger_account_id],
              unique: true, name: 'index_client_ledger_accounts_unique'
  end
end
