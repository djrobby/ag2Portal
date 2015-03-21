class ChangeLedgerAccountInProjects < ActiveRecord::Migration
  def change
    remove_index :projects, :ledger_account
    remove_column :projects, :ledger_account
    
    add_column :projects, :ledger_account_id, :integer
    add_index :projects, :ledger_account_id
  end
end
