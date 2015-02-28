class AddIsContactToSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :is_contact, :boolean
    add_column :suppliers, :shared_contact_id, :integer
    add_index :suppliers, :shared_contact_id
  end
end
