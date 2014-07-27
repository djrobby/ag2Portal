class AddOrganizationToSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :organization_id, :integer
  end
end
