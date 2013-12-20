class AddCreatedByToWorkerSalaries < ActiveRecord::Migration
  def change
    add_column :worker_salaries, :created_by, :integer
    add_column :worker_salaries, :updated_by, :integer
  end
end
