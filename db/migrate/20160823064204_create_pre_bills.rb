class CreatePreBills < ActiveRecord::Migration
  def change
    create_table :pre_bills do |t|
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
      t.references :bill
      t.timestamp :confirmation_date

      t.timestamps
    end
    add_index :pre_bills, :project_id
    add_index :pre_bills, :client_id
    add_index :pre_bills, :subscriber_id
    add_index :pre_bills, :invoice_status_id
    add_index :pre_bills, :street_type_id
    add_index :pre_bills, :zipcode_id
    add_index :pre_bills, :town_id
    add_index :pre_bills, :province_id
    add_index :pre_bills, :region_id
    add_index :pre_bills, :country_id
    add_index :pre_bills, :bill_id
  end
end
