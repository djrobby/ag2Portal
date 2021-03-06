class SharedContact < ActiveRecord::Base
  belongs_to :street_type
  belongs_to :zipcode
  belongs_to :town
  belongs_to :province
  belongs_to :country
  belongs_to :region
  belongs_to :shared_contact_type
  belongs_to :organization
  attr_accessible :building, :cellular, :company, :email, :extension,
                  :fax, :first_name, :fiscal_id, :floor, :floor_office,
                  :last_name, :phone, :position, :street_name, :street_number,
                  :street_type_id, :zipcode_id, :town_id, :province_id,
                  :country_id, :shared_contact_type_id, :remarks, :region_id,
                  :created_by, :updated_by, :organization_id

  has_paper_trail

  validates :first_name,           :presence => true, :if => "company.blank?"
  validates :last_name,            :presence => true, :if => "company.blank?"
  validates :fiscal_id,            :presence => true,
                                   :length => { :minimum => 8 },
                                   :if => "!company.blank?"
  validates :street_type,          :presence => true
  validates :zipcode,              :presence => true
  validates :town,                 :presence => true
  validates :province,             :presence => true
  validates :region,               :presence => true
  validates :country,              :presence => true
  validates :shared_contact_type,  :presence => true
  validates :organization,         :presence => true

  before_validation :fields_to_uppercase

  def self.find_by_fiscal_id_organization_type(_fiscal_id, _organization, _type)
    SharedContact.where("fiscal_id = ? AND organization_id = ? AND shared_contact_type_id = ?", _fiscal_id, _organization, _type).first 
  end

  def self.find_by_name_organization_type(_last, _first, _organization, _type)
    SharedContact.where("last_name = ? AND first_name = ? AND organization_id = ? AND shared_contact_type_id = ?", _last, _first, _organization, _type).first 
  end

  def fields_to_uppercase
    if !self.fiscal_id.blank?
      self[:fiscal_id].upcase!
    end
  end

  def full_name
    full_name = ""
    if !self.last_name.blank?
      full_name += self.last_name
    end
    if !self.first_name.blank?
      full_name += ", " + self.first_name
    end
    full_name
  end
  
  def company_name
    company_name = ""
    if !self.company.blank?
      company_name += self.company
    end
    company_name
  end
  
  def existing_name
    existing_name = ""
    if !self.last_name.blank? && !self.first_name.blank? && !self.company.blank?
      existing_name += full_name + " - " + company_name
    elsif !self.company.blank?
      existing_name += company_name
    else
      existing_name += full_name
    end
    existing_name
  end

  searchable do
    text :first_name, :last_name, :company, :fiscal_id, :cellular, :phone, :email
    string :company
    string :last_name
    string :first_name
    integer :organization_id
    integer :shared_contact_type_id
  end
end