class ContractTemplate < ActiveRecord::Base
  # CONSTANTS
  CONSTANTS = {:All => 0, :WATER_SUPPLY => 1, :WATER_CONNECTION => 2 }

  ALL = 0
  WATER_SUPPLY = 1
  WATER_CONNECTION = 2

  belongs_to :organization
  belongs_to :country
  belongs_to :region
  belongs_to :province
  belongs_to :town

  attr_accessible :for_contract, :name, :organization_id,
                  :country_id, :region_id, :province_id, :town_id

  has_many :contract_template_terms
  has_many :water_supply_companies, :class_name => 'Company', foreign_key: "water_supply_contract_template_id"
  has_many :water_connection_companies, :class_name => 'Company', foreign_key: "water_connection_contract_template_id"
  has_many :water_supply_offices, :class_name => 'Office', foreign_key: "water_supply_contract_template_id"
  has_many :water_connection_offices, :class_name => 'Office', foreign_key: "water_connection_contract_template_id"
  has_many :water_supply_projects, :class_name => 'Project', foreign_key: "water_supply_contract_template_id"
  has_many :water_connection_projects, :class_name => 'Project', foreign_key: "water_connection_contract_template_id"

  has_paper_trail

  validates :name,          :presence => true
  validates :organization,  :presence => true
  validates :for_contract,  :presence => true,
                            :numericality => { :only_integer => true, :greater_than_or_equal_to => 0, :less_than => 3  }

  # Scopes
  scope :by_id, -> { order(:id) }
  #
  scope :belongs_to_organization, -> organization { where("organization_id = ?", organization).by_id }

  before_destroy :check_for_dependent_records

  private

  def check_for_dependent_records
    # Check for contract template terms
    if contract_template_terms.count > 0
      errors.add(:base, I18n.t('activerecord.models.contract_template.check_for_terms'))
      return false
    end
    # Check for water_supply_companies
    if water_supply_companies.count > 0
      errors.add(:base, I18n.t('activerecord.models.contract_template.check_for_companies'))
      return false
    end
    # Check for water_connection_companies
    if water_connection_companies.count > 0
      errors.add(:base, I18n.t('activerecord.models.contract_template.check_for_companies'))
      return false
    end
    # Check for water_supply_offices
    if water_supply_offices.count > 0
      errors.add(:base, I18n.t('activerecord.models.contract_template.check_for_offices'))
      return false
    end
    # Check for water_connection_offices
    if water_connection_offices.count > 0
      errors.add(:base, I18n.t('activerecord.models.contract_template.check_for_offices'))
      return false
    end
    # Check for water_supply_projects
    if water_supply_projects.count > 0
      errors.add(:base, I18n.t('activerecord.models.contract_template.check_for_projects'))
      return false
    end
    # Check for water_connection_projects
    if water_connection_projects.count > 0
      errors.add(:base, I18n.t('activerecord.models.contract_template.check_for_projects'))
      return false
    end
  end
end
