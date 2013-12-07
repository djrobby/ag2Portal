class AddCreatedByToWorkOrderItems < ActiveRecord::Migration
  def change
    add_column :work_order_items, :created_by, :integer
    add_column :work_order_items, :updated_by, :integer
  end
end
