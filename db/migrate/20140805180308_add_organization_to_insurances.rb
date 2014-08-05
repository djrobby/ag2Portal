class AddOrganizationToInsurances < ActiveRecord::Migration
  def change
    add_column :insurances, :organization_id, :integer
    add_index :insurances, :organization_id
  end
end
