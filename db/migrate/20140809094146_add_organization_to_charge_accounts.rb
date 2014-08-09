class AddOrganizationToChargeAccounts < ActiveRecord::Migration
  def change
    add_column :charge_accounts, :organization_id, :integer
  end
end
