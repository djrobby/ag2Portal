class TimerecordType < ActiveRecord::Base
  attr_accessible :name,
                  :created_by, :updated_by

  validates :name,  :presence => true,
                    :length => { :is => 1},
                    :uniqueness => true

  before_validation :fields_to_uppercase

  has_many :time_records
  def fields_to_uppercase
    self[:name].upcase!
  end
end