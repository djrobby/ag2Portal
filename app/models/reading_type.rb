class ReadingType < ActiveRecord::Base
  # CONSTANTS
  NORMAL = 1
  OCTAVILLA = 2
  CONTROL = 3
  INSTALACION = 4
  RETIRADA = 5

  attr_accessible :name

  has_many :pre_readings
  has_many :readings

  validates :name,         :presence => true

  def to_label
    "#{name}"
  end

end
