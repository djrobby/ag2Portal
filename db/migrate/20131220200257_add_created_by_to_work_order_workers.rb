class AddCreatedByToWorkOrderWorkers < ActiveRecord::Migration
  def change
    add_column :work_order_workers, :created_by, :integer
    add_column :work_order_workers, :updated_by, :integer
  end
end
