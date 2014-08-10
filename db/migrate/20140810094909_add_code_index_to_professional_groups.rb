class AddCodeIndexToProfessionalGroups < ActiveRecord::Migration
  def change
    add_index :professional_groups, :organization_id    
    add_index :professional_groups, :pg_code    
  end
end
