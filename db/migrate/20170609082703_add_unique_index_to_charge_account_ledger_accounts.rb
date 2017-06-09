class AddUniqueIndexToChargeAccountLedgerAccounts < ActiveRecord::Migration
  def change
    add_index :charge_account_ledger_accounts,
              [:charge_account_id, :ledger_account_id],
              unique: true, name: 'index_charge_account_ledger_accounts_unique'
  end
end
