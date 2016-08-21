module Ag2Tech
  class Api::V1::ClientsSerializer < ::Api::V1::BaseSerializer
    attributes :id, :active, :building, :cellular, :client_code, :email, :fax, :fiscal_id, :floor, :floor_office,
                    :first_name, :last_name, :company, :phone, :remarks, :street_name, :street_number, :organization_id,
                    :entity_id, :street_type_id, :zipcode_id, :town_id, :province_id, :region_id, :country_id,
                    :is_contact, :shared_contact_id, :ledger_account_id, :payment_method_id,
                    :created_at, :created_by, :updated_at, :updated_by

    has_one :entity
    has_one :street_type
    has_one :zipcode
    has_one :town
    has_one :province
    has_one :region
    has_one :country
    has_one :ledger_account
    has_one :payment_method
  end
end
