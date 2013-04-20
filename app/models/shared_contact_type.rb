class SharedContactType < ActiveRecord::Base
  attr_accessible :name

  has_many :shared_contacts
end
