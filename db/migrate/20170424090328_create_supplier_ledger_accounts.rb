class CreateSupplierLedgerAccounts < ActiveRecord::Migration
  def change
    create_table :supplier_ledger_accounts do |t|
      t.references :supplier
      t.references :ledger_account

      t.timestamps
    end
    add_index :supplier_ledger_accounts, :supplier_id
    add_index :supplier_ledger_accounts, :ledger_account_id
  end
end
