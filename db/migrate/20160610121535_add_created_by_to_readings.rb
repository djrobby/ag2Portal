class AddCreatedByToReadings < ActiveRecord::Migration
  def change
    add_column :readings, :created_by, :integer
    add_column :readings, :updated_by, :integer
  end
end
