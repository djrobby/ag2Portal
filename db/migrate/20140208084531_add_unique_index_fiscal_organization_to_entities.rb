class AddUniqueIndexFiscalOrganizationToEntities < ActiveRecord::Migration
  def change
    remove_index :entities, :organization_id
    remove_index :entities, :fiscal_id
    
    add_index :entities, [:organization_id, :fiscal_id], unique: true
  end
end
