module Ag2Tech
  class Api::V1::StoresSerializer < ::Api::V1::BaseSerializer
    attributes :id, :location, :name, :company_id, :office_id,
                    :organization_id, :supplier_id,
                    :street_type_id, :street_name, :street_number, :building, :floor, :floor_office,
                    :zipcode_id, :town_id, :province_id, :phone, :fax, :email,
                    :created_at, :created_by, :updated_at, :updated_by

    has_one :company
    has_one :office
    has_one :supplier
    has_one :province
    has_one :town
    has_one :zipcode
    has_one :street_type
  end
end
