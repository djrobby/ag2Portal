class AddCreatedByToWorkerSalaryItems < ActiveRecord::Migration
  def change
    add_column :worker_salary_items, :created_by, :integer
    add_column :worker_salary_items, :updated_by, :integer
  end
end
