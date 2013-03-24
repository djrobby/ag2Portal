class Company < ActiveRecord::Base
  attr_accessible :fiscal_id, :name
  
  validates :name,  :presence => true
  validates fiscal_id, :presence => true,
                       :length => { :minimum => 9 }
                       
  has_many :offices
end
