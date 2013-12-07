class AddCreatedByToWorkOrderTypes < ActiveRecord::Migration
  def change
    add_column :work_order_types, :created_by, :integer
    add_column :work_order_types, :updated_by, :integer
  end
end
