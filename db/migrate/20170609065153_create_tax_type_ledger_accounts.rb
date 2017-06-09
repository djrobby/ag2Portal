class CreateTaxTypeLedgerAccounts < ActiveRecord::Migration
  def change
    create_table :tax_type_ledger_accounts do |t|
      t.references :tax_type
      t.references :input_ledger_account
      t.references :output_ledger_account

      t.timestamps
    end
    add_index :tax_type_ledger_accounts, :tax_type_id
    add_index :tax_type_ledger_accounts, :input_ledger_account_id
    add_index :tax_type_ledger_accounts, :output_ledger_account_id
  end
end
