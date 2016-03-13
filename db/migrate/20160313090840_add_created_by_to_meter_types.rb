class AddCreatedByToMeterTypes < ActiveRecord::Migration
  def change
    add_column :meter_types, :created_by, :integer
    add_column :meter_types, :updated_by, :integer
  end
end
