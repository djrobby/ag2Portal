class Project < ActiveRecord::Base
  belongs_to :company
  belongs_to :office
  attr_accessible :closed_at, :ledger_account, :name, :opened_at,
                  :office_id, :company_id, :project_code

  has_many :charge_accounts
  has_many :work_orders
  has_many :purchase_orders
  has_many :receipt_notes
  has_many :offer_requests
  has_many :supplier_invoices
  

  has_paper_trail

  validates :name,          :presence => true
  validates :project_code,  :presence => true,
                            :length => { :minimum => 6 },
                            :uniqueness => true
  validates :opened_at,     :presence => true
  validates :company,       :presence => true
  validates :office,        :presence => true

  before_destroy :check_for_dependent_records

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = ""
    if !self.project_code.blank?
      full_name += self.project_code
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
    Project.order("id").first
  end

  def to_prev
    Project.where("id < ?", id).order("id").last
  end

  def to_next
    Project.where("id > ?", id).order("id").first
  end

  def to_last
    Project.order("id").last
  end

  searchable do
    text :project_code, :name
    string :project_code
  end

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
    # Check for receipt notes
    if receipt_notes.count > 0
      errors.add(:base, I18n.t('activerecord.models.project.check_for_receipt_notes'))
      return false
    end
    # Check for offer requests
    if offer_requests.count > 0
      errors.add(:base, I18n.t('activerecord.models.project.check_for_offer_requests'))
      return false
    end
    # Check for supplier invoices
    if supplier_invoices.count > 0
      errors.add(:base, I18n.t('activerecord.models.project.check_for_supplier_invoices'))
      return false
    end
  end
end
