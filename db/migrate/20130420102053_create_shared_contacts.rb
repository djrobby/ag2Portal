class CreateSharedContacts < ActiveRecord::Migration
  def change
    create_table :shared_contacts do |t|
      t.string :first_name
      t.string :last_name
      t.string :company
      t.string :fiscal_id
      t.string :position
      t.references :street_type
      t.string :street_name
      t.string :street_number
      t.string :building
      t.integer :floor
      t.string :floor_office
      t.references :zipcode
      t.references :town
      t.references :province
      t.references :country
      t.string :phone
      t.string :extension
      t.string :fax
      t.string :cellular
      t.string :email
      t.references :shared_contact_type

      t.timestamps
    end
    add_index :shared_contacts, :street_type_id
    add_index :shared_contacts, :zipcode_id
    add_index :shared_contacts, :town_id
    add_index :shared_contacts, :province_id
    add_index :shared_contacts, :country_id
    add_index :shared_contacts, :shared_contact_type_id
    add_index :shared_contacts, :fiscal_id
    add_index :shared_contacts, :first_name
    add_index :shared_contacts, :company
    add_index :shared_contacts, :last_name
    add_index :shared_contacts, :email
    add_index :shared_contacts, :phone
    add_index :shared_contacts, :cellular
  end
end
