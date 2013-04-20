class Province < ActiveRecord::Base
  attr_accessible :ine_cpro, :name

  validates :name,      :presence => true
  validates :ine_cpro,  :length => { :minimum => 2 }
                       
  has_many :towns
  has_many :zipcodes
  has_many :companies
  has_many :offices
  has_many :workers
  has_many :shared_contacts
end
