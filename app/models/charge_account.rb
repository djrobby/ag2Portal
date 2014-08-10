class ChargeAccount < ActiveRecord::Base
  belongs_to :project
  belongs_to :organization
  attr_accessible :closed_at, :ledger_account, :name, :opened_at,
                  :project_id, :account_code, :organization_id

  has_many :work_orders
  has_many :purchase_orders
  has_many :receipt_notes
  has_many :receipt_note_items
  has_many :supplier_invoices

  has_paper_trail

  validates :account_code,  :presence => true,
                            :length => { :in => 7..17 },
                            :uniqueness => { :scope => :organization_id }
  validates :name,          :presence => true
  validates :opened_at,     :presence => true
  validates :organization,  :presence => true

  before_destroy :check_for_dependent_records

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = ""
    if !self.account_code.blank?
      full_name += self.account_code
    end
    if !self.name.blank?
      full_name += " " + self.name[0,40]
    end
    full_name
  end

  #
  # Records navigator
  #
  def to_first
    ChargeAccount.order("account_code").first
  end

  def to_prev
    ChargeAccount.where("account_code < ?", id).order("account_code").last
  end

  def to_next
    ChargeAccount.where("account_code > ?", id).order("account_code").first
  end

  def to_last
    ChargeAccount.order("account_code").last
  end

  searchable do
    text :account_code, :name
    string :account_code
    integer :project_id
    integer :organization_id
  end

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
    # Check for supplier invoices
    if supplier_invoices.count > 0
      errors.add(:base, I18n.t('activerecord.models.charge_account.check_for_supplier_invoices'))
      return false
    end
  end
end
