class ChangeYearInMeters < ActiveRecord::Migration
  def change
    change_column :meters, :manufacturing_year, :integer, :limit => 2, :null => false, :default => '0'
  end
end
