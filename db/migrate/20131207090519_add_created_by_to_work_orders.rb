class AddCreatedByToWorkOrders < ActiveRecord::Migration
  def change
    add_column :work_orders, :created_by, :integer
    add_column :work_orders, :updated_by, :integer
  end
end
