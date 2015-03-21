class ChangeLedgerAccountInSuppliers < ActiveRecord::Migration
  def change
    remove_index :suppliers, :ledger_account
    remove_column :suppliers, :ledger_account
    
    add_column :suppliers, :ledger_account_id, :integer
    add_index :suppliers, :ledger_account_id
  end
end
