class AddCreatedByToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :created_by, :integer
    add_column :projects, :updated_by, :integer
  end
end
