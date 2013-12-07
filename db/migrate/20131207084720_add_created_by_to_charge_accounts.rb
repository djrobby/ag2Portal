class AddCreatedByToChargeAccounts < ActiveRecord::Migration
  def change
    add_column :charge_accounts, :created_by, :integer
    add_column :charge_accounts, :updated_by, :integer
  end
end
