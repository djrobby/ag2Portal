class ReadingIncidence < ActiveRecord::Base
  belongs_to :reading
  belongs_to :reading_incidence_type
  attr_accessible :reading_id, :reading_incidence_type_id, :created_at
end
