class AddCreatedByToClientBankAccounts < ActiveRecord::Migration
  def change
    add_column :client_bank_accounts, :created_by, :integer
    add_column :client_bank_accounts, :updated_by, :integer
  end
end
