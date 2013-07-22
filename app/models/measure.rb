class Measure < ActiveRecord::Base
  attr_accessible :description

  has_paper_trail

  validates :description, :presence => true
end
