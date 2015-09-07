class AddCreatedByToSupplierBankAccounts < ActiveRecord::Migration
  def change
    add_column :supplier_bank_accounts, :created_by, :integer
    add_column :supplier_bank_accounts, :updated_by, :integer
  end
end
