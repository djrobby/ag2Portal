class SharedContactType < ActiveRecord::Base
  attr_accessible :name,
                  :created_by, :updated_by

  has_many :shared_contacts

  has_paper_trail
end
