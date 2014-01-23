class AddOrganizationToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :organization_id, :integer

    add_index :companies, :organization_id
  end
end
