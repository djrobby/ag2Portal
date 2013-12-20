class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.references :entity
      t.string :client_code
      t.string :name
      t.string :fiscal_id
      t.references :street_type
      t.string :street_name
      t.string :street_number
      t.string :building
      t.integer :floor
      t.string :floor_office
      t.references :zipcode
      t.references :town
      t.references :province
      t.references :region
      t.references :country
      t.string :phone
      t.string :fax
      t.string :cellular
      t.string :email
      t.boolean :active
      t.string :remarks

      t.timestamps
    end
    add_index :clients, :entity_id
    add_index :clients, :street_type_id
    add_index :clients, :zipcode_id
    add_index :clients, :town_id
    add_index :clients, :province_id
    add_index :clients, :region_id
    add_index :clients, :country_id
    add_index :clients, :name
    add_index :clients, :client_code
    add_index :clients, :fiscal_id
  end
end
