class AddRemarksToSharedContacts < ActiveRecord::Migration
  def change
    add_column :shared_contacts, :remarks, :string
  end
end
