class AddUniqueIndexCodeOrganizationToProducts < ActiveRecord::Migration
  def change
    remove_index :products, :product_code
    
    add_index :products, [:organization_id, :product_code], unique: true
  end
end
