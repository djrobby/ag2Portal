class SharedContact < ActiveRecord::Base
  belongs_to :street_type
  belongs_to :zipcode
  belongs_to :town
  belongs_to :province
  belongs_to :country
  belongs_to :shared_contact_type
  attr_accessible :building, :cellular, :company, :email, :extension,
                  :fax, :first_name, :fiscal_id, :floor, :floor_office,
                  :last_name, :phone, :position, :street_name, :street_number,
                  :street_type_id, :zipcode_id, :town_id, :province_id,
                  :country_id, :shared_contact_type_id, :remarks

  validates :first_name,              :presence => true, :if => "company.blank?"
  validates :last_name,               :presence => true, :if => "company.blank?"
  validates :fiscal_id,               :presence => true, :if => "!company.blank?"
  validates :street_type_id,          :presence => true
  validates :zipcode_id,              :presence => true
  validates :town_id,                 :presence => true
  validates :province_id,             :presence => true
  validates :country_id,              :presence => true
  validates :shared_contact_type_id,  :presence => true

  before_validation :fields_to_uppercase

  searchable do
    text :first_name, :last_name, :company, :fiscal_id, :cellular, :phone, :email
  end

  def fields_to_uppercase
    self[:fiscal_id].upcase!
  end
end