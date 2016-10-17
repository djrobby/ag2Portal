class ServicePoint < ActiveRecord::Base
  belongs_to :service_point_type
  belongs_to :service_point_location
  belongs_to :service_point_purpose
  belongs_to :water_connection
  belongs_to :organization
  belongs_to :company
  belongs_to :office
  belongs_to :center
  belongs_to :street_directory
  belongs_to :zipcode
  belongs_to :reading_route
  attr_accessible :available_for_contract, :building, :cadastral_reference, :code, :diameter, :floor, :floor_office,
                  :gis_id, :name, :reading_sequence, :reading_variant, :street_number, :verified,
                  :service_point_type_id, :service_point_location_id, :service_point_purpose_id,
                  :water_connection_id, :organization_id, :company_id, :office_id, :center_id,
                  :street_directory_id, :zipcode_id, :reading_route_id, :km

  has_many :subscribers

  def to_full_label
    if street_directory.nil?
      "#{street_type.street_type_code} #{street_name}, #{street_number} #{floor} #{floor_office}, (#{town.name})"
    else
      "#{street_directory.street_type.street_type_code} #{street_directory.street_name}, #{street_number} #{floor} #{floor_office}, (#{street_directory.town.name})"
    end
  end
end
