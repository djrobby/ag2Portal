class AddCreatedByToWaterConnectionTypes < ActiveRecord::Migration
  def change
    add_column :water_connection_types, :created_by, :integer
    add_column :water_connection_types, :updated_by, :integer
  end
end
