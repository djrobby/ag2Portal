class AddLetterToMeterModels < ActiveRecord::Migration
  def change
    add_column :meter_models, :letter_id, :string, :limit => 1
  end
end
