class AddCreatedByToPreReadings < ActiveRecord::Migration
  def change
    add_column :pre_readings, :created_by, :integer
    add_column :pre_readings, :updated_by, :integer
  end
end
