class ReadingRoute < ActiveRecord::Base
  belongs_to :project
  belongs_to :office
  attr_accessible :name, :routing_code
end
