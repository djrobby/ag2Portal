class AddCreatedByToLedgerAccounts < ActiveRecord::Migration
  def change
    add_column :ledger_accounts, :created_by, :integer
    add_column :ledger_accounts, :updated_by, :integer
  end
end
