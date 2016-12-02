class ContractedTariff < ActiveRecord::Base
  belongs_to :water_supply_contract
  belongs_to :tariff
  # attr_accessible :title, :body
end
