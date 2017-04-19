class AddCompanyToLedgerAccounts < ActiveRecord::Migration
  def change
    add_column :ledger_accounts, :company_id, :integer

    add_index :ledger_accounts, :company_id
  end
end
