class WaterConnectionType < ActiveRecord::Base
  # CONSTANTS
  SUM = 1
  SAN = 2

  attr_accessible :name

  has_many :water_connections
  has_many :water_connection_contracts

  has_paper_trail

  validates :name,  :presence => true

  before_destroy :check_for_dependent_records

  private

  # Before destroy
  def check_for_dependent_records
    # Check for water_connections
    if water_connections.count > 0
      errors.add(:base, I18n.t('activerecord.models.water_connection_type.check_for_water_connections'))
      return false
    end
    # Check for water_connection_contracts
    if water_connection_contracts.count > 0
      errors.add(:base, I18n.t('activerecord.models.water_connection_type.check_for_water_connection_contracts'))
      return false
    end
  end
end
