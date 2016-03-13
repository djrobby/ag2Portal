class ChangeCaliberInCalibers < ActiveRecord::Migration
  def change
    change_column :calibers, :caliber, :integer, :limit => 2, :null => false, :default => '0'
  end
end
