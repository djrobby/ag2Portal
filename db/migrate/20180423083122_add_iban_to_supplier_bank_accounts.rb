class AddIbanToSupplierBankAccounts < ActiveRecord::Migration
  def self.up
    add_column :supplier_bank_accounts, :iban, :string, limit: 50
    add_index :supplier_bank_accounts, :iban

    SupplierBankAccount.find_each do |p|
      p.update_column(:iban, p.e_format)
    end
  end

  def self.down
    remove_index :supplier_bank_accounts, :iban
    remove_column :supplier_bank_accounts, :iban
  end
end
