class AddUniqueIndexToSupplierLedgerAccounts < ActiveRecord::Migration
  def change
    add_index :supplier_ledger_accounts,
              [:supplier_id, :ledger_account_id],
              unique: true, name: 'index_supplier_ledger_accounts_unique'
  end
end
