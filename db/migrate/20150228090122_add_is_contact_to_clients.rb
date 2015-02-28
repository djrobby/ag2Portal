class AddIsContactToClients < ActiveRecord::Migration
  def change
    add_column :clients, :is_contact, :boolean
    add_column :clients, :shared_contact_id, :integer
    add_index :clients, :shared_contact_id
  end
end
