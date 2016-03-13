class AddCreatedByToMeterModels < ActiveRecord::Migration
  def change
    add_column :meter_models, :created_by, :integer
    add_column :meter_models, :updated_by, :integer
  end
end
