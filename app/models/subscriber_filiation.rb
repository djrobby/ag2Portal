class SubscriberFiliation < ActiveRecord::Base
  belongs_to :subscriber
  belongs_to :street_directory

  attr_accessible :subscriber_id, :subscriber_code, :name, :supply_address, :meter_code,
                  :use_id, :reading_route_id, :office_id, :center_id, :street_directory_id, :everything
end
