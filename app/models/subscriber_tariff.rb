class SubscriberTariff < ActiveRecord::Base
  belongs_to :subscriber
  belongs_to :tariff
  # attr_accessible :title, :body
end
