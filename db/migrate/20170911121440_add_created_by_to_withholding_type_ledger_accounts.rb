class AddCreatedByToWithholdingTypeLedgerAccounts < ActiveRecord::Migration
  def change
    add_column :withholding_type_ledger_accounts, :created_by, :integer
    add_column :withholding_type_ledger_accounts, :updated_by, :integer
  end
end
