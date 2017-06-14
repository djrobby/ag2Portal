class AddCompanyToChargeAccountLedgerAccounts < ActiveRecord::Migration
  def change
    add_column :charge_account_ledger_accounts, :company_id, :integer

    add_index :charge_account_ledger_accounts, :company_id
  end
end
