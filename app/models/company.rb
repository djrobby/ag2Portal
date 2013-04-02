class Company < ActiveRecord::Base
  belongs_to :province
  belongs_to :town
  belongs_to :zipcode
  belongs_to :street_type
  attr_accessible :fiscal_id, :name,
                  :street_type_id, :street_name, :street_number, :building, :floor, :floor_office,
                  :zipcode_id, :town_id, :province_id, :phone, :fax, :cellular, :email

  validates :name,            :presence => true
  validates :fiscal_id,       :presence => true,
                              :length => { :minimum => 9 },
                              :uniqueness => true
  validates :street_type_id,  :presence => true
  validates :zipcode_id,      :presence => true
  validates :town_id,         :presence => true
  validates :province_id,     :presence => true

  before_validation :fields_to_uppercase

  has_many :offices
  has_many :workers
  def fields_to_uppercase
    self[:fiscal_id].upcase!
  end
end
