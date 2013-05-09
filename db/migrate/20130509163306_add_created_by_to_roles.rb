class AddCreatedByToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :created_by, :integer
    add_column :roles, :updated_by, :integer
  end
end
