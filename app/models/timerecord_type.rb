class TimerecordType < ActiveRecord::Base
  attr_accessible :name

  validates :name,  :presence => true,
                    :length => { :is => 1},
                    :uniqueness => true

  before_validation :fields_to_uppercase

  has_many :time_records
  def fields_to_uppercase
    self[:name].upcase!
  end
end
