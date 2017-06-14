class AddCompanyToTaxTypeLedgerAccounts < ActiveRecord::Migration
  def change
    add_column :tax_type_ledger_accounts, :company_id, :integer

    add_index :tax_type_ledger_accounts, :company_id
  end
end
