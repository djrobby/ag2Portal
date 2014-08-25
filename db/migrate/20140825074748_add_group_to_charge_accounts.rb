class AddGroupToChargeAccounts < ActiveRecord::Migration
  def change
    add_column :charge_accounts, :charge_group_id, :integer
    add_index :charge_accounts, :charge_group_id    
  end
end
