class AddCodeIndexToSuppliers < ActiveRecord::Migration
  def change
    add_index :suppliers, :organization_id    
    add_index :suppliers, :fiscal_id    
    add_index :suppliers, :supplier_code    
  end
end
