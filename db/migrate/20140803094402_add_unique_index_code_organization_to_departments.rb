class AddUniqueIndexCodeOrganizationToDepartments < ActiveRecord::Migration
  def change
    remove_index :departments, :organization_id
    remove_index :departments, :code
    
    add_index :departments, [:organization_id, :code], unique: true
  end
end
