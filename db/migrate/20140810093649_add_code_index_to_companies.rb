class AddCodeIndexToCompanies < ActiveRecord::Migration
  def change
    add_index :companies, :organization_id    
    add_index :companies, :fiscal_id    
  end
end
