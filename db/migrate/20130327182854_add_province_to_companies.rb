class AddProvinceToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :street_type_id, :integer
    add_column :companies, :street_name, :string
    add_column :companies, :street_number, :string
    add_column :companies, :building, :string
    add_column :companies, :floor, :integer
    add_column :companies, :floor_office, :string
    add_column :companies, :zipcode_id, :integer
    add_column :companies, :town_id, :integer
    add_column :companies, :province_id, :integer

    add_index :companies, :street_type_id
    add_index :companies, :zipcode_id
    add_index :companies, :town_id
    add_index :companies, :province_id
  end
end
