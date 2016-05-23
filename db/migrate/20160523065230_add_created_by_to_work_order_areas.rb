class AddCreatedByToWorkOrderAreas < ActiveRecord::Migration
  def change
    add_column :work_order_areas, :created_by, :integer
    add_column :work_order_areas, :updated_by, :integer
  end
end
