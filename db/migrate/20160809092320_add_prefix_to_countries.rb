class AddPrefixToCountries < ActiveRecord::Migration
  def change
    add_column :countries, :prefix, :integer, :limit => 2, :null => false, :default => '0'
  end
end
