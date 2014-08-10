class AddCodeIndexToChargeAccounts < ActiveRecord::Migration
  def change
    add_index :charge_accounts, :organization_id    
    add_index :charge_accounts, :account_code    
  end
end
