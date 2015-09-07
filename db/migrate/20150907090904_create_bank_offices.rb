class CreateBankOffices < ActiveRecord::Migration
  def change
    create_table :bank_offices do |t|
      t.string :code
      t.string :name
      t.references :bank
      t.string :swift
      t.references :street_type
      t.string :street_name
      t.string :street_number
      t.string :building
      t.string :floor
      t.string :floor_office
      t.references :zipcode
      t.references :town
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
    add_index :bank_offices, :bank_id
    add_index :bank_offices, :street_type_id
    add_index :bank_offices, :zipcode_id
    add_index :bank_offices, :town_id
    add_index :bank_offices, :province_id
    add_index :bank_offices, :region_id
    add_index :bank_offices, :country_id
    add_index :bank_offices, :code
    add_index :bank_offices, :name
    add_index :bank_offices, :swift
    add_index :bank_offices, [:bank_id, :code], unique: true
  end
end
