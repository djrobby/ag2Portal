class AddUniqueIndexCodeOrganizationToProductFamilies < ActiveRecord::Migration
  def change
    add_index :product_families, :organization_id    
    add_index :product_families, [:organization_id, :family_code], unique: true
  end
end
