class WaterConnection < ActiveRecord::Base
  belongs_to :water_connection_type
  attr_accessible :code, :gis_id, :name, :water_connection_type_id

  has_paper_trail

  validates :code,                    :presence => true
  validates :water_connection_type,   :presence => true
end
