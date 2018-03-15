class Api::V1::SubscriberSupplyAddressesSerializer < ::Api::V1::BaseSerializer
  attributes :id, :subscriber_id, :supply_address, :text

  def id
    subscriber_id
  end

  def text
    supply_address
  end
end
