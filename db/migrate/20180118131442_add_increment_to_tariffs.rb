class AddIncrementToTariffs < ActiveRecord::Migration
  def change
    add_column :tariffs, :endowments_increment, :integer, :limit => 2, :null => false, :default => '0'
    add_column :tariffs, :inhabitants_increment, :integer, :limit => 2, :null => false, :default => '0'
  end
end
