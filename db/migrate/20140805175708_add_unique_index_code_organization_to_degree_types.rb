class AddUniqueIndexCodeOrganizationToDegreeTypes < ActiveRecord::Migration
  def change
    remove_index :degree_types, :dt_code
    
    add_index :degree_types, [:organization_id, :dt_code], unique: true
  end
end
