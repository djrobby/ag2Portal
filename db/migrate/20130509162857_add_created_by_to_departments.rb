class AddCreatedByToDepartments < ActiveRecord::Migration
  def change
    add_column :departments, :created_by, :integer
    add_column :departments, :updated_by, :integer
  end
end
