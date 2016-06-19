class ChangeIndexInReadings < ActiveRecord::Migration
  def change
    change_column :readings, :reading_index, :integer, :null => false, :default => '0'
  end
end
