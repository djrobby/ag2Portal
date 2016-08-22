class CreateContractingRequests < ActiveRecord::Migration
  def change
    create_table :contracting_requests do |t|
      t.string :request_no
      t.references :project
      t.date :request_date
      t.references :entity
      t.references :contracting_request_type
      t.references :contracting_request_status
      t.string :r_last_name
      t.string :r_first_name
      t.string :r_fiscal_id
      t.references :entity_street_directory
      t.references :entity_street_type
      t.string :entity_fiscal_id
      t.string :entity_street_name
      t.string :entity_street_number
      t.string :entity_building
      t.string :entity_floor
      t.string :entity_floor_office
      t.references :entity_zipcode
      t.references :entity_town
      t.references :entity_province
      t.references :entity_region
      t.references :entity_country
      t.string :entity_phone
      t.string :entity_fax
      t.string :entity_cellular
      t.string :entity_email
      t.string :client_last_name
      t.string :client_first_name
      t.string :client_company
      t.references :client_street_directory
      t.references :client_street_type
      t.string :client_street_name
      t.string :client_street_number
      t.string :client_building
      t.string :client_floor
      t.string :client_floor_office
      t.references :client_zipcode
      t.references :client_town
      t.references :client_province
      t.references :client_region
      t.references :client_country
      t.string :client_phone
      t.string :client_fax
      t.string :client_cellular
      t.string :client_email
      t.string :subscriber_last_name
      t.string :subscriber_first_name
      t.string :subscriber_company
      t.references :subscriber_street_directory
      t.references :subscriber_street_type
      t.string :subscriber_street_name
      t.string :subscriber_street_number
      t.string :subscriber_building
      t.string :subscriber_floor
      t.string :subscriber_floor_office
      t.references :subscriber_zipcode
      t.references :subscriber_town
      t.references :subscriber_province
      t.references :subscriber_region
      t.references :subscriber_country
      t.references :subscriber_center
      t.string :subscriber_phone
      t.string :subscriber_fax
      t.string :subscriber_cellular
      t.string :subscriber_email
      t.references :country
      t.string :iban_dc, :length => 2
      t.references :bank
      t.references :bank_office
      t.string :ccc_dc, :length => 2
      t.string :account_no, :length => 10
      t.references :work_order
      t.references :subscriber
      t.references :service_point

      t.timestamps
    end
    add_index :contracting_requests, :project_id
    add_index :contracting_requests, :entity_id
    add_index :contracting_requests, :contracting_request_type_id
    add_index :contracting_requests, :contracting_request_status_id
    add_index :contracting_requests, :r_fiscal_id
    add_index :contracting_requests, :entity_street_directory_id
    add_index :contracting_requests, :entity_street_type_id
    add_index :contracting_requests, :entity_zipcode_id
    add_index :contracting_requests, :entity_town_id
    add_index :contracting_requests, :entity_province_id
    add_index :contracting_requests, :entity_region_id
    add_index :contracting_requests, :entity_country_id
    add_index :contracting_requests, :client_street_directory_id
    add_index :contracting_requests, :client_street_type_id
    add_index :contracting_requests, :client_zipcode_id
    add_index :contracting_requests, :client_town_id
    add_index :contracting_requests, :client_province_id
    add_index :contracting_requests, :client_region_id
    add_index :contracting_requests, :client_country_id
    add_index :contracting_requests, :subscriber_street_directory_id
    add_index :contracting_requests, :subscriber_street_type_id
    add_index :contracting_requests, :subscriber_zipcode_id
    add_index :contracting_requests, :subscriber_town_id
    add_index :contracting_requests, :subscriber_province_id
    add_index :contracting_requests, :subscriber_region_id
    add_index :contracting_requests, :subscriber_country_id
    add_index :contracting_requests, :subscriber_center_id
    add_index :contracting_requests, :work_order_id
    add_index :contracting_requests, :subscriber_id
    add_index :contracting_requests, :service_point_id
    add_index :contracting_requests, :country_id
    add_index :contracting_requests, :bank_id
    add_index :contracting_requests, :bank_office_id
  end
end
