class AddIbanToCompanyBankAccounts < ActiveRecord::Migration
  def self.up
    add_column :company_bank_accounts, :iban, :string, limit: 50
    add_index :company_bank_accounts, :iban

    CompanyBankAccount.find_each do |p|
      p.update_column(:iban, p.e_format)
    end
  end

  def self.down
    remove_index :company_bank_accounts, :iban
    remove_column :company_bank_accounts, :iban
  end
end
