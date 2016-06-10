class Reading < ActiveRecord::Base
  belongs_to :project
  belongs_to :billing_period
  belongs_to :billing_frequency
  belongs_to :reading_type
  belongs_to :meter
  belongs_to :subscriber
  belongs_to :reading_route
  attr_accessible :reading_date, :reading_index, :reading_sequence, :reading_variant
end
