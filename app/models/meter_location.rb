class MeterLocation < ActiveRecord::Base
  attr_accessible :name

  has_paper_trail

  validates :name,  :presence => true

  has_many :meter_details
end
