class Country < ActiveRecord::Base
  attr_accessible :name,
                  :created_by, :updated_by

  has_paper_trail

  validates :name,  :presence => true

  has_many :shared_contacts
  has_many :regions
  has_many :entities
  has_many :suppliers
end
