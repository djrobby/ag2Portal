class Company < ActiveRecord::Base
  belongs_to :province
  belongs_to :town
  belongs_to :zipcode
  belongs_to :street_type
  attr_accessible :fiscal_id, :name, :street_type_id, :street_name, :street_number, :building, :floor, :floor_office, :zipcode_id, :town_id, :province_id
  
  validates :name,            :presence => true
  validates :fiscal_id,       :presence => true,
                              :length => { :minimum => 9 }
  validates :street_type_id,  :presence => true
  validates :zipcode_id,      :presence => true
  validates :town_id,         :presence => true
  validates :province_id,     :presence => true
  
  has_many :offices
end
