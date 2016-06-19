class AddCreatedByToMeterDetails < ActiveRecord::Migration
  def change
    add_column :meter_details, :created_by, :integer
    add_column :meter_details, :updated_by, :integer
  end
end
