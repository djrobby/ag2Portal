class AddDigitsToMeterModels < ActiveRecord::Migration
  def change
    add_column :meter_models, :digits, :integer, :limit => 1, :null => false, :default => '0'
    add_column :meter_models, :dials, :integer, :limit => 1, :null => false, :default => '1'
  end
end
