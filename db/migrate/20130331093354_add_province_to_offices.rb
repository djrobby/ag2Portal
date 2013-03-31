class AddProvinceToOffices < ActiveRecord::Migration
  def change
    add_column :offices, :street_type_id, :integer
    add_column :offices, :street_name, :string
    add_column :offices, :street_number, :string
    add_column :offices, :building, :string
    add_column :offices, :floor, :integer
    add_column :offices, :floor_office, :string
    add_column :offices, :zipcode_id, :integer
    add_column :offices, :town_id, :integer
    add_column :offices, :province_id, :integer
    add_column :offices, :phone, :string
    add_column :offices, :fax, :string
    add_column :offices, :cellular, :string
    add_column :offices, :email, :string

    add_index :offices, :street_type_id
    add_index :offices, :zipcode_id
    add_index :offices, :town_id
    add_index :offices, :province_id
  end
end
