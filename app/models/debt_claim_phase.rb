class DebtClaimPhase < ActiveRecord::Base
  attr_accessible :name, :surcharge_pct

  has_many :debt_claims

  has_paper_trail

  validates :name,          :presence => true
  validates :surcharge_pct, :numericality => { :greater_than_or_equal_to => 0 }

  before_destroy :check_for_dependent_records
  before_save :init_surcharge_pct

  private

  def check_for_dependent_records
    # Check for debt claims
    if debt_claims.count > 0
      errors.add(:base, I18n.t('activerecord.models.debt_claim_phase.check_for_debt_claims'))
      return false
    end
  end

  # Before save (create & update)
  def init_surcharge_pct
    self.surcharge_pct = 0 if surcharge_pct.blank?
    true
  end
end
