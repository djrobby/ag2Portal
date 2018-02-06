class AddClientBankAccountsCountToClients < ActiveRecord::Migration
  def self.up
    add_column :clients, :client_bank_accounts_count, :integer, :default => 0

    Client.reset_column_information
    Client.find_each do |p|
      Client.reset_counters p.id, :client_bank_accounts
    end
  end

  def self.down
    remove_column :clients, :client_bank_accounts_count
  end
end
