class AddCreatedByToWorkOrderSubcontractors < ActiveRecord::Migration
  def change
    add_column :work_order_subcontractors, :created_by, :integer
    add_column :work_order_subcontractors, :updated_by, :integer
  end
end
