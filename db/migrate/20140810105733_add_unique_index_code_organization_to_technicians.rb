class AddUniqueIndexCodeOrganizationToTechnicians < ActiveRecord::Migration
  def change
    add_index :technicians, :organization_id    
    add_index :technicians, [:organization_id, :user_id], unique: true
  end
end
