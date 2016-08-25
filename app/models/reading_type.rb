class ReadingType < ActiveRecord::Base
  attr_accessible :name

  has_many :pre_readings
  has_many :readings
end
