class AddCreatedByToWorkOrderTools < ActiveRecord::Migration
  def change
    add_column :work_order_tools, :created_by, :integer
    add_column :work_order_tools, :updated_by, :integer
  end
end
