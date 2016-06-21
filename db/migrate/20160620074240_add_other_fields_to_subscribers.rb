class AddOtherFieldsToSubscribers < ActiveRecord::Migration
  def change
    add_column :subscribers, :street_number, :string
    add_column :subscribers, :building, :string
    add_column :subscribers, :floor, :integer
    add_column :subscribers, :floor_office, :string
    add_column :subscribers, :zipcode_id, :integer
    add_column :subscribers, :phone, :string
    add_column :subscribers, :fax, :string
    add_column :subscribers, :cellular, :string
    add_column :subscribers, :email, :string
    add_column :subscribers, :service_point_id, :integer
    add_column :subscribers, :active, :boolean
    add_column :subscribers, :tariff_scheme_id, :integer
    add_column :subscribers, :billing_frequency_id, :integer
    add_column :subscribers, :meter_id, :integer
    add_column :subscribers, :reading_route_id, :integer
    add_column :subscribers, :reading_sequence, :integer
    add_column :subscribers, :reading_variant, :string
    add_column :subscribers, :contracting_request_id, :integer
    add_column :subscribers, :remarks, :string
    add_column :subscribers, :cadastral_reference, :string
    add_column :subscribers, :gis_id, :string
    add_column :subscribers, :endownments, :integer, :limit => 2, :null => false, :default => '0'
    add_column :subscribers, :inhabitants, :integer, :limit => 2, :null => false, :default => '0'

    add_index :subscribers, :zipcode_id
    add_index :subscribers, :email
    add_index :subscribers, :phone
    add_index :subscribers, :cellular
    add_index :subscribers, :service_point_id
    add_index :subscribers, :tariff_scheme_id
    add_index :subscribers, :billing_frequency_id
    add_index :subscribers, :meter_id
    add_index :subscribers, :reading_route_id
    add_index :subscribers, :reading_sequence
    add_index :subscribers, :reading_variant
    add_index :subscribers, :contracting_request_id
    add_index :subscribers, :cadastral_reference
    add_index :subscribers, :gis_id
  end
end
