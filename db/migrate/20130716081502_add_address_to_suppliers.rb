class AddAddressToSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :street_type_id, :integer
    add_column :suppliers, :street_name, :string
    add_column :suppliers, :street_number, :string
    add_column :suppliers, :building, :string
    add_column :suppliers, :floor, :integer
    add_column :suppliers, :floor_office, :string
    add_column :suppliers, :zipcode_id, :integer
    add_column :suppliers, :town_id, :integer
    add_column :suppliers, :province_id, :integer
    add_column :suppliers, :phone, :string
    add_column :suppliers, :fax, :string
    add_column :suppliers, :cellular, :string
    add_column :suppliers, :email, :string

    add_index :suppliers, :street_type_id
    add_index :suppliers, :street_name
    add_index :suppliers, :zipcode_id
    add_index :suppliers, :town_id
    add_index :suppliers, :province_id
    add_index :suppliers, :phone
    add_index :suppliers, :fax
    add_index :suppliers, :cellular
    add_index :suppliers, :email
  end
end
