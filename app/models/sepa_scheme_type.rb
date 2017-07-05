class SepaSchemeType < ActiveRecord::Base
  attr_accessible :name

  has_paper_trail

  validates :name,  :presence => true
end
