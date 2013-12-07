class AddCodeToChargeAccounts < ActiveRecord::Migration
  def change
    add_column :charge_accounts, :account_code, :string
    add_index :charge_accounts, :account_code
  end
end
