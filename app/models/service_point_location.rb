class ServicePointLocation < ActiveRecord::Base
  attr_accessible :name

  has_many :service_points
end
