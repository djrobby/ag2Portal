class WaterConnectionContract < ActiveRecord::Base
  belongs_to :contracting_request
  belongs_to :water_connection_type
  belongs_to :client
  belongs_to :work_order
  belongs_to :sale_offer
  belongs_to :tariff
  belongs_to :bill

  attr_accessible :contract_date, :remarks, :contracting_request_id, :water_connection_type_id,
                  :client_id, :work_order_id, :sale_offer_id, :tariff_id, :bill_id

  # validates

  # callbacks

  # methods
end
