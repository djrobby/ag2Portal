class AddOrganizationToProductFamilies < ActiveRecord::Migration
  def change
    add_column :product_families, :organization_id, :integer
  end
end
