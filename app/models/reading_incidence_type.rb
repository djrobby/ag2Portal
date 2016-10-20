class ReadingIncidenceType < ActiveRecord::Base
  has_many :reading_incidences
  has_many :pre_reading_incidences

  attr_accessible :name, :should_estimate

  validates :name,         :presence => true

  def to_label
    "#{name}"
  end

end
