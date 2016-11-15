class MeterDetail < ActiveRecord::Base
  belongs_to :meter
  belongs_to :subscriber
  belongs_to :meter_location
  attr_accessible :installation_date, :installation_reading, :withdrawal_date, :withdrawal_reading,
                  :meter_id, :subscriber_id, :meter_location_id, :created_by, :updated_by

  has_paper_trail

  validates :meter,                                 :presence => true
  validates :meter_location,                        :presence => true
  validates :installation_date,                     :presence => true
  validates_numericality_of :installation_reading,  :only_integer => true,
                                                    :allow_nil => true,
                                                    :greater_than_or_equal_to => 0,
                                                    :message => :reading_invalid

  # Scopes
  scope :by_dates, -> { order(:meter_id, :installation_date, :withdrawal_date) }
end
