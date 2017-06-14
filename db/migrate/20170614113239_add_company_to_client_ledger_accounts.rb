class AddCompanyToClientLedgerAccounts < ActiveRecord::Migration
  def change
    add_column :client_ledger_accounts, :company_id, :integer

    add_index :client_ledger_accounts, :company_id
  end
end
