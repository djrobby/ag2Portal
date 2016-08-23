class CreateBills < ActiveRecord::Migration
  def change
    create_table :bills do |t|
      t.string :bill_no
      t.references :project
      t.references :client
      t.references :subscriber
      t.references :invoice_status
      t.date :bill_date
      t.string :last_name
      t.string :first_name
      t.string :company
      t.string :fiscal_id
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

      t.timestamps
    end
    add_index :bills, :project_id
    add_index :bills, :client_id
    add_index :bills, :subscriber_id
    add_index :bills, :invoice_status_id
    add_index :bills, :street_type_id
    add_index :bills, :zipcode_id
    add_index :bills, :town_id
    add_index :bills, :province_id
    add_index :bills, :region_id
    add_index :bills, :country_id
  end
end
