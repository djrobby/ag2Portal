class DebtClaimStatus < ActiveRecord::Base
  attr_accessible :action, :name

  has_many :debt_claim_items

  has_paper_trail

  validates :name,          :presence => true
  validates :action,        :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }

  before_destroy :check_for_dependent_records
  before_save :init_action

  private

  def check_for_dependent_records
    # Check for debt claim items
    if debt_claim_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.debt_claim_status.check_for_debt_claims'))
      return false
    end
  end

  # Before save (create & update)
  def init_action
    # 0->nothing to do
    # 1->create child claim
    # 2->create child claim & activate not-billable subscriber
    # 3->do no create child claim & activate not-billable subscriber
    # 4->??
    self.action = 0 if action.blank?
    true
  end
end
