class AddLedgerAccountAppCodeToWithholdingTypes < ActiveRecord::Migration
  def change
    add_column :withholding_types, :ledger_account_app_code, :string
  end
end
