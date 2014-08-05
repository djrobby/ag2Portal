class AddUniqueIndexCodeOrganizationToCollectiveAgreements < ActiveRecord::Migration
  def change
    remove_index :collective_agreements, :ca_code
    
    add_index :collective_agreements, [:organization_id, :ca_code], unique: true
  end
end
