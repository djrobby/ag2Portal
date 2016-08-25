class ReadingRoute < ActiveRecord::Base
  belongs_to :project
  belongs_to :office
  attr_accessible :name, :routing_code, :project_id, :office_id

  has_many :subscribers
  has_many :pre_readings
  has_many :readings
  has_many :service_points
  has_many :water_supply_contracts
end
