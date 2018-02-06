class AddClientBankAccountsCountToSubscribers < ActiveRecord::Migration
  def self.up
    add_column :subscribers, :client_bank_accounts_count, :integer, :default => 0

    Subscriber.reset_column_information
    Subscriber.find_each do |p|
      Subscriber.reset_counters p.id, :client_bank_accounts
    end
  end

  def self.down
    remove_column :subscribers, :client_bank_accounts_count
  end
end
