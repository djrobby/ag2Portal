class ChangeLedgerAccountInChargeGroups < ActiveRecord::Migration
  def change
    remove_index :charge_groups, :ledger_account
    remove_column :charge_groups, :ledger_account
    
    add_column :charge_groups, :ledger_account_id, :integer
    add_index :charge_groups, :ledger_account_id
  end
end
