class AddCodeIndexToEntities < ActiveRecord::Migration
  def change
    add_index :entities, :organization_id    
    add_index :entities, :fiscal_id    
  end
end
