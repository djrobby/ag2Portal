class AddCreatedByToWorkOrderLabors < ActiveRecord::Migration
  def change
    add_column :work_order_labors, :created_by, :integer
    add_column :work_order_labors, :updated_by, :integer
  end
end
