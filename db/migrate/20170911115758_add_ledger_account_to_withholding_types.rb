class AddLedgerAccountToWithholdingTypes < ActiveRecord::Migration
  def change
    add_column :withholding_types, :ledger_account_id, :integer
  end
end
