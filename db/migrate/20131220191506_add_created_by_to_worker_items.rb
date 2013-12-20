class AddCreatedByToWorkerItems < ActiveRecord::Migration
  def change
    add_column :worker_items, :created_by, :integer
    add_column :worker_items, :updated_by, :integer
  end
end
