class AddUniqueIndexCodeOrganizationToChargeAccounts < ActiveRecord::Migration
  def change
    remove_index :charge_accounts, :account_code    
    add_index :charge_accounts, [:organization_id, :account_code], unique: true
  end
end
