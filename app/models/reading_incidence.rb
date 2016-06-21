class ReadingIncidence < ActiveRecord::Base
  belongs_to :reading
  belongs_to :reading_incidence
  # attr_accessible :title, :body
end
