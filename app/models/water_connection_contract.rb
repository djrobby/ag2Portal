class WaterConnectionContract < ActiveRecord::Base
  belongs_to :contracting_request
  belongs_to :water_connection_type
  belongs_to :client
  belongs_to :work_order
  belongs_to :sale_offer
  belongs_to :tariff
  belongs_to :bill

  attr_accessible :contract_date, :remarks, :contracting_request_id, :water_connection_type_id,
                  :client_id, :work_order_id, :sale_offer_id, :tariff_id, :bill_id, :contract_no

  # validates

  # callbacks

  # methods
  def full_no
    # Contract no (Project Id & Request type Id & year & sequential number) => PPPPPP-TT-YYYY-NNNNNN
    contract_no.blank? ? "" : contract_no[0..5] + '-' + contract_no[6..7] + '-' + contract_no[8..11] + '-' + contract_no[12..17]
  end
end
