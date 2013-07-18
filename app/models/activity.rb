class Activity < ActiveRecord::Base
  attr_accessible :description

  has_paper_trail

  validates :description, :presence => true

  has_many :suppliers_activities
end
