class PreReadingIncidence < ActiveRecord::Base
  belongs_to :pre_reading
  belongs_to :reading_incidence_type
  attr_accessible :pre_reading_id, :reading_incidence_type_id
end
