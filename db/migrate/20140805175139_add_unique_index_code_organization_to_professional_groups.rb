class AddUniqueIndexCodeOrganizationToProfessionalGroups < ActiveRecord::Migration
  def change
    remove_index :professional_groups, :pg_code
    
    add_index :professional_groups, [:organization_id, :pg_code], unique: true
  end
end
