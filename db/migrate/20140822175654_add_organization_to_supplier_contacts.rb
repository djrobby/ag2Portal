class AddOrganizationToSupplierContacts < ActiveRecord::Migration
  def change
    add_column :supplier_contacts, :organization_id, :integer
    add_index :supplier_contacts, :organization_id    
  end
end
