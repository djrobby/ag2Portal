class AddCreatedByToWorkerTypes < ActiveRecord::Migration
  def change
    add_column :worker_types, :created_by, :integer
    add_column :worker_types, :updated_by, :integer
  end
end
