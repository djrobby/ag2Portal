class SubscriberTariff < ActiveRecord::Base
  belongs_to :subscriber
  belongs_to :tariff
  attr_accessible :subscriber_id, :tariff_id, :started_at, :ending_at

  validates :subscriber,  :presence => true
  validates :tariff,      :presence => true
  validates :starting_at, :presence => true
end
