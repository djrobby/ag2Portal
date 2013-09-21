class CreateEntities < ActiveRecord::Migration
  def change
    create_table :entities do |t|
      t.string :fiscal_id
      t.string :first_name
      t.string :last_name
      t.string :company
      t.references :entity_type
      t.references :street_type
      t.string :street_name
      t.string :street_number
      t.string :building
      t.integer :floor
      t.string :floor_office
      t.references :zipcode
      t.string :town
      t.references :province
      t.references :region
      t.references :country
      t.string :phone
      t.string :extension
      t.string :fax
      t.string :cellular
      t.string :email

      t.timestamps
    end
    add_index :entities, :entity_type_id
    add_index :entities, :street_type_id
    add_index :entities, :zipcode_id
    add_index :entities, :province_id
    add_index :entities, :region_id
    add_index :entities, :country_id
    add_index :entities, :fiscal_id
    add_index :entities, :first_name
    add_index :entities, :last_name
    add_index :entities, :company
    add_index :entities, :email
    add_index :entities, :phone
    add_index :entities, :cellular
  end
end
