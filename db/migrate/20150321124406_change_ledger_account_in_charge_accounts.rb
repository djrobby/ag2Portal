class ChangeLedgerAccountInChargeAccounts < ActiveRecord::Migration
  def change
    remove_index :charge_accounts, :ledger_account
    remove_column :charge_accounts, :ledger_account
    
    add_column :charge_accounts, :ledger_account_id, :integer
    add_index :charge_accounts, :ledger_account_id
  end
end
