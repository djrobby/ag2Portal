class TimerecordCode < ActiveRecord::Base
  attr_accessible :name

  validates :name,  :presence => true

  has_many :time_records
end
