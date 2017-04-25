class AddLedgerAccountsToTaxTypes < ActiveRecord::Migration
  def change
    add_column :tax_types, :input_ledger_account, :integer
    add_column :tax_types, :output_ledger_account, :integer

    add_index :tax_types, :input_ledger_account
    add_index :tax_types, :output_ledger_account
  end
end
