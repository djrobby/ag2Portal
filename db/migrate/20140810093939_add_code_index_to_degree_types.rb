class AddCodeIndexToDegreeTypes < ActiveRecord::Migration
  def change
    add_index :degree_types, :organization_id    
    add_index :degree_types, :dt_code    
  end
end
