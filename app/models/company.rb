class Company < ActiveRecord::Base
  belongs_to :province
  belongs_to :town
  belongs_to :zipcode
  belongs_to :street_type
  attr_accessible :fiscal_id, :name,
                  :street_type_id, :street_name, :street_number, :building, :floor, :floor_office,
                  :zipcode_id, :town_id, :province_id, :phone, :fax, :cellular, :email,
                  :invoice_code, :invoice_header, :invoice_footer, :invoice_left_margin

  validates :name,            :presence => true
  validates :fiscal_id,       :presence => true,
                              :length => { :minimum => 9 },
                              :uniqueness => true
  validates :street_type_id,  :presence => true
  validates :zipcode_id,      :presence => true
  validates :town_id,         :presence => true
  validates :province_id,     :presence => true
  validates :invoice_code,    :presence => true

  before_validation :fields_to_uppercase

  has_many :offices
  has_many :workers
  has_many :corp_contacts, :order => 'last_name, first_name'
  def fields_to_uppercase
    self[:fiscal_id].upcase!
    self[:invoice_code].upcase!
  end
end
