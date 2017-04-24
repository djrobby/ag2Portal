class CreateChargeGroupLedgerAccounts < ActiveRecord::Migration
  def change
    create_table :charge_group_ledger_accounts do |t|
      t.references :charge_group
      t.references :ledger_account

      t.timestamps
    end
    add_index :charge_group_ledger_accounts, :charge_group_id
    add_index :charge_group_ledger_accounts, :ledger_account_id
  end
end
