class Country < ActiveRecord::Base
  attr_accessible :name

  has_many :shared_contacts
  has_many :regions
end
