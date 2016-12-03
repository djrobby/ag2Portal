class ServicePointType < ActiveRecord::Base
  attr_accessible :name

  has_many :service_points

  has_paper_trail

  validates :name,  :presence => true
end
