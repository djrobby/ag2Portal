class SubscriberSupplyAddress < ActiveRecord::Base
  belongs_to :subscriber

  attr_accessible :subscriber_id, :supply_address
end
