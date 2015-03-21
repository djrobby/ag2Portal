class AddLedgerAccountToClients < ActiveRecord::Migration
  def change
    add_column :clients, :ledger_account_id, :integer
    add_index :clients, :ledger_account_id
  end
end
