class AddCodeIndexToDepartments < ActiveRecord::Migration
  def change
    add_index :departments, :organization_id    
    add_index :departments, :code    
  end
end
