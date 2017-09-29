class WaterConnectionContractItem < ActiveRecord::Base
  belongs_to :water_connection_contract
  belongs_to :water_connection_contract_item_type
    
  attr_accessor :flow, :quantity_flow
  attr_accessible :quantity, :water_connection_contract_item_type_id, :water_connection_contract_id, :flow, :quantity_flow

  has_paper_trail

  #
  # Calculated fields
  #
  def quantity_flow
    self.water_connection_contract_item_type.flow * quantity  if !water_connection_contract_item_type.nil?
  end

end