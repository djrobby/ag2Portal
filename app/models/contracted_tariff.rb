class ContractedTariff < ActiveRecord::Base
  belongs_to :water_supply_contract
  belongs_to :tariff
  attr_accessible :water_supply_contract_id, :tariff_id, :started_at, :ending_at

  validates :water_supply_contract, :presence => true
  validates :tariff,                :presence => true
  validates :starting_at,           :presence => true

  before_validation :assign_at

  has_paper_trail

  private

  def assign_at
    self.starting_at = tariff.starting_at
    self.ending_at = tariff.ending_at
  end
end
