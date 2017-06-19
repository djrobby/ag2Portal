class RenameLedgerAccountColumnsInTaxTypes < ActiveRecord::Migration
  def change
    remove_index :tax_types, :input_ledger_account
    remove_index :tax_types, :output_ledger_account

    rename_column :tax_types, :input_ledger_account, :input_ledger_account_id
    rename_column :tax_types, :output_ledger_account, :output_ledger_account_id

    add_index :tax_types, :input_ledger_account_id
    add_index :tax_types, :output_ledger_account_id
  end
end
