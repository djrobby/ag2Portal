class WaterConnection < ActiveRecord::Base
  belongs_to :water_connection_type
  attr_accessible :code, :gis_id, :name
end
