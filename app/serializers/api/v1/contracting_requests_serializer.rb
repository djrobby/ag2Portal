class Api::V1::ContractingRequestsSerializer < ::Api::V1::BaseSerializer
  attributes :id, :request_date,
                  :request_no, :text

  has_one :water_supply_contract
  has_one :water_connection_contract

  def text
    _f = full_no
    _f += " " + (contracting_client.nil? ? "N/A" : contracting_client.full_name_or_company)
  end

  def contracting_client
    _f = nil
    if !water_supply_contract.nil?
      _f = water_supply_contract.client.nil? ? nil : water_supply_contract.client
    elsif !water_connection_contract.nil?
      _f = !water_connection_contract.client.nil? ? nil : !water_connection_contract.client
    end
    _f
  end

  def full_no
    # Request no (Project code & year & sequential number) => PPPPPPPPPPPP-YYYY-NNNNNN
    request_no.blank? ? "" : request_no[0..11] + '-' + request_no[12..15] + '-' + request_no[16..21]
  end
end
