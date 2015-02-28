class AddIsContactToSupplierContacts < ActiveRecord::Migration
  def change
    add_column :supplier_contacts, :is_contact, :boolean
    add_column :supplier_contacts, :shared_contact_id, :integer
    add_index :supplier_contacts, :shared_contact_id
  end
end
