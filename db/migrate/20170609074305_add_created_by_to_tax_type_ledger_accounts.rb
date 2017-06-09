class AddCreatedByToTaxTypeLedgerAccounts < ActiveRecord::Migration
  def change
    add_column :tax_type_ledger_accounts, :created_by, :integer
    add_column :tax_type_ledger_accounts, :updated_by, :integer
  end
end
