class ServicePoint < ActiveRecord::Base
  belongs_to :service_point_type
  belongs_to :service_point_location
  belongs_to :service_point_purpose
  belongs_to :water_connection
  belongs_to :organization
  belongs_to :company
  belongs_to :office
  belongs_to :street_directory
  belongs_to :zipcode
  belongs_to :reading_route
  attr_accessible :available_for_contract, :building, :cadastral_reference, :code, :diameter, :floor, :floor_office, :gis_id, :name, :reading_sequence, :reading_variant, :street_number, :verified
end
