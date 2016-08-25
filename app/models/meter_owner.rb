class MeterOwner < ActiveRecord::Base
  attr_accessible :name

  has_many :meters

  has_paper_trail

  validates :name,  :presence => true
end
