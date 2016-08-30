class WaterConnectionType < ActiveRecord::Base
  attr_accessible :name

  has_many :water_connections
  has_many :water_connection_contracts
end
