class AddOriginToClientBankAccounts < ActiveRecord::Migration
  def self.up
    add_column :client_bank_accounts, :origin, :integer, limit: 1, null: false, default: 1

    ClientBankAccount.find_each do |p|
      p.update_column(:origin, 1)
    end
  end

  def self.down
    remove_column :client_bank_accounts, :origin
  end
end
