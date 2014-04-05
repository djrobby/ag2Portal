class AddCodeToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :project_code, :string
    add_column :projects, :organization_id, :integer

    add_index :projects, [:organization_id, :project_code], unique: true
  end
end
