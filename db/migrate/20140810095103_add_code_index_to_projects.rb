class AddCodeIndexToProjects < ActiveRecord::Migration
  def change
    add_index :projects, :organization_id    
    add_index :projects, :project_code    
  end
end
