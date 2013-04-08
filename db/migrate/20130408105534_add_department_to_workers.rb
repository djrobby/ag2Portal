class AddDepartmentToWorkers < ActiveRecord::Migration
  def change
    add_column :workers, :department_id, :integer

    add_index :workers, :department_id
  end
end
