class AddOrganizationSupplierToStores < ActiveRecord::Migration
  def change
    add_column :stores, :organization_id, :integer
    add_column :stores, :supplier_id, :integer

    add_index :stores, :organization_id
    add_index :stores, :supplier_id
  end
end
