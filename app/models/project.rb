class Project < ActiveRecord::Base
  belongs_to :company
  belongs_to :office
  attr_accessible :closed_at, :ledger_account, :name, :opened_at,
                  :office_id, :company_id

  has_many :charge_accounts
  has_many :work_orders
  has_many :purchase_orders

  has_paper_trail

  validates :name,      :presence => true
  validates :opened_at, :presence => true
  validates :company,   :presence => true
  validates :office,    :presence => true

  before_destroy :check_for_dependent_records

  private

  def check_for_dependent_records
    # Check for charge accounts
    if charge_accounts.count > 0
      errors.add(:base, I18n.t('activerecord.models.project.check_for_charge_accounts'))
      return false
    end
    # Check for work orders
    if work_orders.count > 0
      errors.add(:base, I18n.t('activerecord.models.project.check_for_work_orders'))
      return false
    end
    # Check for purchase orders
    if purchase_orders.count > 0
      errors.add(:base, I18n.t('activerecord.models.project.check_for_purchase_orders'))
      return false
    end
  end
end
