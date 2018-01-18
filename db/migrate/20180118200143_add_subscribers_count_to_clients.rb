class AddSubscribersCountToClients < ActiveRecord::Migration
  def self.up
    add_column :clients, :subscribers_count, :integer, :default => 0

    Client.reset_column_information
    Client.find_each do |p|
      Client.reset_counters p.id, :subscribers
    end
  end

  def self.down
    remove_column :clients, :subscribers_count
  end
end
