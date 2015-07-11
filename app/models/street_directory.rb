class StreetDirectory < ActiveRecord::Base
  belongs_to :town
  belongs_to :street_type
  attr_accessible :street_name
end
