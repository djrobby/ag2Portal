class WaterConnectionContractItem < ActiveRecord::Base
  belongs_to :water_connection_contract
  belongs_to :water_connection_contract_item_type
  attr_accessible :quantity
end
