class AddUsersToTariffs < ActiveRecord::Migration
  def change
    add_column :tariffs, :endowments_increment_apply_to, :integer, :limit => 2, :null => false, :default => '0'
    add_column :tariffs, :inhabitants_increment_apply_to, :integer, :limit => 2, :null => false, :default => '0'
    add_column :tariffs, :users_from, :integer, :limit => 2, :null => false, :default => '0'
    add_column :tariffs, :users_increment, :integer, :limit => 2, :null => false, :default => '0'
    add_column :tariffs, :users_increment_apply_to, :integer, :limit => 2, :null => false, :default => '0'
  end
end
