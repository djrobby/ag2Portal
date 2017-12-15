class ReadingIncidence < ActiveRecord::Base
  belongs_to :reading
  belongs_to :reading_incidence_type
  attr_accessible :reading_id, :reading_incidence_type_id, :created_at

  def should_estimate?
    reading_incidence_type.should_estimate rescue false
  end

  #
  # Class (self) user defined methods
  #
  # Reading incidences to be estimated
  def self.reading_should_be_estimated(r=null)
    _ret = false
    if !r.blank?
      where(reading_id: r).each do |i|
        if i.should_estimate?
          _ret = true
          break
        end
      end
    end
    _ret
  end
end
