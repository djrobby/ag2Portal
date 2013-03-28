class Company < ActiveRecord::Base
  belongs_to :province
  belongs_to :town
  belongs_to :zipcode
  attr_accessible :fiscal_id, :name, :street_name, :street_number, :building, :floor, :floor_office, :province_id, :town_id, :zipcode
  
  validates :name,  :presence => true
  validates :fiscal_id, :presence => true,
                       :length => { :minimum => 9 }
                       
  has_many :offices
end
