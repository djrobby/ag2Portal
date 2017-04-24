class CreateClientLedgerAccounts < ActiveRecord::Migration
  def change
    create_table :client_ledger_accounts do |t|
      t.references :client
      t.references :ledger_account

      t.timestamps
    end
    add_index :client_ledger_accounts, :client_id
    add_index :client_ledger_accounts, :ledger_account_id
  end
end
