class CreateChargeAccountLedgerAccounts < ActiveRecord::Migration
  def change
    create_table :charge_account_ledger_accounts do |t|
      t.references :charge_account
      t.references :ledger_account

      t.timestamps
    end
    add_index :charge_account_ledger_accounts, :charge_account_id
    add_index :charge_account_ledger_accounts, :ledger_account_id
  end
end
