class AddCreatedByToChargeAccountLedgerAccounts < ActiveRecord::Migration
  def change
    add_column :charge_account_ledger_accounts, :created_by, :integer
    add_column :charge_account_ledger_accounts, :updated_by, :integer
  end
end
