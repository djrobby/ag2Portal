class ChargeAccount < ActiveRecord::Base
  belongs_to :project
  attr_accessible :closed_at, :ledger_account, :name, :opened_at,
                  :project_id, :account_code

  has_many :work_orders
  has_many :purchase_orders
  has_many :receipt_notes
  has_many :receipt_note_items

  has_paper_trail

  validates :account_code,  :presence => true,
                            :length => { :in => 7..17 },
                            :uniqueness => true
  validates :name,          :presence => true
  validates :opened_at,     :presence => true

  before_destroy :check_for_dependent_records

  private

  def check_for_dependent_records
    # Check for purchase orders
    if purchase_orders.count > 0
      errors.add(:base, I18n.t('activerecord.models.charge_account.check_for_purchase_orders'))
      return false
    end
    # Check for work orders
    if work_orders.count > 0
      errors.add(:base, I18n.t('activerecord.models.charge_account.check_for_work_orders'))
      return false
    end
    # Check for receipt notes
    if receipt_notes.count > 0
      errors.add(:base, I18n.t('activerecord.models.charge_account.check_for_receipt_notes'))
      return false
    end
    # Check for receipt note items
    if receipt_note_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.charge_account.check_for_receipt_notes'))
      return false
    end
  end
end
