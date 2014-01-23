class Company < ActiveRecord::Base
  belongs_to :province
  belongs_to :town
  belongs_to :zipcode
  belongs_to :street_type
  belongs_to :organization
  attr_accessible :fiscal_id, :name,
                  :street_type_id, :street_name, :street_number, :building, :floor, :floor_office,
                  :zipcode_id, :town_id, :province_id, :phone, :fax, :cellular, :email, :logo,
                  :invoice_code, :invoice_header, :invoice_footer, :invoice_left_margin,
                  :created_by, :updated_by, :organization_id
  has_attached_file :logo, :styles => { :medium => "120x120>", :small => "80x80>" }, :default_url => "/images/missing/:style/company.png"

  has_many :offices
  has_many :workers
  has_many :corp_contacts, :order => 'last_name, first_name'
  has_many :projects

  has_paper_trail

  validates :name,         :presence => true
  validates :fiscal_id,    :presence => true,
                           :length => { :minimum => 9 },
                           :uniqueness => true
  validates :street_type,  :presence => true
  validates :zipcode,      :presence => true
  validates :town,         :presence => true
  validates :province,     :presence => true
  validates :invoice_code, :presence => true
  validates :organization, :presence => true

  before_validation :fields_to_uppercase

  def fields_to_uppercase
    if !self.fiscal_id.blank?
      self[:fiscal_id].upcase!
    end
    if !self.invoice_code.blank?
      self[:invoice_code].upcase!
    end
  end
end
