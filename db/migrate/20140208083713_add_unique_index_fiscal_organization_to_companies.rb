class AddUniqueIndexFiscalOrganizationToCompanies < ActiveRecord::Migration
  def change
    remove_index :companies, :organization_id
    remove_index :companies, :fiscal_id
    
    add_index :companies, [:organization_id, :fiscal_id], unique: true
  end
end
