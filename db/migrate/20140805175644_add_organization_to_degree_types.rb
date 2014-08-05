class AddOrganizationToDegreeTypes < ActiveRecord::Migration
  def change
    add_column :degree_types, :organization_id, :integer
  end
end
