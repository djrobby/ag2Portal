class AddProvinceToStores < ActiveRecord::Migration
  def change
    add_column :stores, :street_type_id, :integer
    add_column :stores, :street_name, :string
    add_column :stores, :street_number, :string
    add_column :stores, :building, :string
    add_column :stores, :floor, :integer
    add_column :stores, :floor_office, :string
    add_column :stores, :zipcode_id, :integer
    add_column :stores, :town_id, :integer
    add_column :stores, :province_id, :integer
    add_column :stores, :phone, :string
    add_column :stores, :fax, :string
    add_column :stores, :email, :string

    add_index :stores, :street_type_id
    add_index :stores, :zipcode_id
    add_index :stores, :town_id
    add_index :stores, :province_id
  end
end
