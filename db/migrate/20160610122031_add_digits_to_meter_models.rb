class AddDigitsToMeterModels < ActiveRecord::Migration
  def change
    add_column :meter_models, :digits, :integer
    add_column :meter_models, :dials, :integer
  end
end
