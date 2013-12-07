class AddCreatedByToWorkOrderStatuses < ActiveRecord::Migration
  def change
    add_column :work_order_statuses, :created_by, :integer
    add_column :work_order_statuses, :updated_by, :integer
  end
end
