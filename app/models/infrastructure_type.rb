class InfrastructureType < ActiveRecord::Base
  belongs_to :organization
  attr_accessible :name, :organization_id

  has_many :infrastructures

  has_paper_trail

  validates :name,          :presence => true
  validates :organization,  :presence => true

  before_destroy :check_for_dependent_records

  private

  def check_for_dependent_records
    # Check for infrastructures
    if infrastructures.count > 0
      errors.add(:base, I18n.t('activerecord.models.infrastructure_type.check_for_infrastructures'))
      return false
    end
  end
end
