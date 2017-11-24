class AddPostalAddressToSubscribers < ActiveRecord::Migration
  def change
    add_column :subscribers, :postal_last_name, :string
    add_column :subscribers, :postal_first_name, :string
    add_column :subscribers, :postal_street_directory_id, :integer
    add_column :subscribers, :postal_street_type_id, :integer
    add_column :subscribers, :postal_street_name, :string
    add_column :subscribers, :postal_street_number, :string
    add_column :subscribers, :postal_building, :string
    add_column :subscribers, :postal_floor, :string
    add_column :subscribers, :postal_floor_office, :string
    add_column :subscribers, :postal_zipcode_id, :integer
    add_column :subscribers, :postal_town_id, :integer
    add_column :subscribers, :postal_province_id, :integer
    add_column :subscribers, :postal_region_id, :integer
    add_column :subscribers, :postal_country_id, :integer

    add_index :subscribers, :postal_street_directory_id
    add_index :subscribers, :postal_street_type_id
    add_index :subscribers, :postal_zipcode_id
    add_index :subscribers, :postal_town_id
    add_index :subscribers, :postal_province_id
    add_index :subscribers, :postal_region_id
    add_index :subscribers, :postal_country_id
  end
end
