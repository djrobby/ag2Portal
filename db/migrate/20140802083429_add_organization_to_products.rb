class AddOrganizationToProducts < ActiveRecord::Migration
  def change
    add_column :products, :organization_id, :integer
  end
end
