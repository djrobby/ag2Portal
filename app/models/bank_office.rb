class BankOffice < ActiveRecord::Base
  belongs_to :bank
  belongs_to :street_type
  belongs_to :zipcode
  belongs_to :town
  belongs_to :province
  belongs_to :region
  belongs_to :country
  attr_accessible :building, :cellular, :code, :email, :extension, :fax, :floor, :floor_office, :name, :phone, :street_name, :street_number
end
