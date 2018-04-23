class AddIbanToClientBankAccounts < ActiveRecord::Migration
  def self.up
    add_column :client_bank_accounts, :iban, :string, limit: 50
    add_index :client_bank_accounts, :iban

    ClientBankAccount.find_each do |p|
      p.update_column(:iban, p.e_format)
    end
  end

  def self.down
    remove_index :client_bank_accounts, :iban
    remove_column :client_bank_accounts, :iban
  end
end
