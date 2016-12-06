class ContractedTariff < ActiveRecord::Base
  belongs_to :water_supply_contract
  belongs_to :tariff
  attr_accessible :water_supply_contract_id, :tariff_id, :started_at, :ending_at

  validates :water_supply_contract, :presence => true
  validates :tariff,                :presence => true
  validates :starting_at,           :presence => true
end
