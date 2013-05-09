class AddCreatedByToSharedContacts < ActiveRecord::Migration
  def change
    add_column :shared_contacts, :created_by, :integer
    add_column :shared_contacts, :updated_by, :integer
  end
end
