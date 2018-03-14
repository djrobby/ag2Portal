class Api::V1::SubscriberSupplyAddressesSerializer < ::Api::V1::BaseSerializer
  attributes :subscriber_id, :supply_address, :text

  def text
    supply_address
  end
end
