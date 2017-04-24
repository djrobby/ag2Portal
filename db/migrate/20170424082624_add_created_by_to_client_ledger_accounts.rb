class AddCreatedByToClientLedgerAccounts < ActiveRecord::Migration
  def change
    add_column :client_ledger_accounts, :created_by, :integer
    add_column :client_ledger_accounts, :updated_by, :integer
  end
end
