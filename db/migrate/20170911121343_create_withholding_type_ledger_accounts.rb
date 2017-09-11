class CreateWithholdingTypeLedgerAccounts < ActiveRecord::Migration
  def change
    create_table :withholding_type_ledger_accounts do |t|
      t.references :withholding_type
      t.references :ledger_account
      t.references :company

      t.timestamps
    end
    add_index :withholding_type_ledger_accounts, :withholding_type_id
    add_index :withholding_type_ledger_accounts, :ledger_account_id
    add_index :withholding_type_ledger_accounts, :company_id
  end
end
