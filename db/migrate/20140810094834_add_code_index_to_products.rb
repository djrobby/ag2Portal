class AddCodeIndexToProducts < ActiveRecord::Migration
  def change
    add_index :products, :organization_id    
    add_index :products, :product_code    
  end
end
