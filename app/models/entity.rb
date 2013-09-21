class Entity < ActiveRecord::Base
  belongs_to :entity_type
  belongs_to :street_type
  belongs_to :zipcode
  belongs_to :province
  belongs_to :region
  belongs_to :country
  attr_accessible :building, :cellular, :company, :email, :extension, :fax, :first_name, :fiscal_id, :floor, :floor_office, :last_name, :phone, :street_name, :street_number, :town
end
