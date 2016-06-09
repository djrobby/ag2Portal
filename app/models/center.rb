class Center < ActiveRecord::Base
  belongs_to :town
  attr_accessible :active, :name
end
