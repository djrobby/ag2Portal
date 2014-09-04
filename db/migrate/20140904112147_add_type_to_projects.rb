class AddTypeToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :project_type_id, :integer
    add_index :projects, :project_type_id
  end
end
