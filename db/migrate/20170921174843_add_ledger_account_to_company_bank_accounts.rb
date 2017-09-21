class AddLedgerAccountToCompanyBankAccounts < ActiveRecord::Migration
  def change
    add_column :company_bank_accounts, :ledger_account_id, :integer

    add_index :company_bank_accounts, :ledger_account_id
  end
end
