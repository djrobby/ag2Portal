class SubscriberSupplyAddress < ActiveRecord::Base
  belongs_to :subscriber

  attr_accessible :subscriber_id, :supply_address

  # Scopes
  scope :by_address, -> { order('subscriber_supply_addresses.supply_address') }
  # generic where, including subscriber to fetch office_id (eg. for Select2 from engines_controller)
  scope :g_where, -> w {
    joins(:subscriber)
    .select("subscriber_supply_addresses.subscriber_id, subscriber_supply_addresses.supply_address")
    .where(w).by_address
  }
end
