class SupplierInvoice < ActiveRecord::Base
  belongs_to :supplier
  belongs_to :payment_method
  belongs_to :project
  belongs_to :work_order
  belongs_to :charge_account
  attr_accessible :discount, :discount_pct, :invoice_date, :invoice_no, :remarks,
                  :supplier_id, :payment_method_id, :project_id, :work_order_id, :charge_account_id

  has_many :supplier_invoice_items, dependent: :destroy
  has_many :supplier_invoice_approvals, dependent: :destroy
  has_many :supplier_payments

  has_paper_trail

  validates :invoice_date,   :presence => true
  validates :invoice_no,     :presence => true
  validates :supplier,       :presence => true
  validates :payment_method, :presence => true

  before_destroy :check_for_dependent_records

  #
  # Records navigator
  #
  def to_first
    SupplierInvoice.order("id").first
  end

  def to_prev
    SupplierInvoice.where("id < ?", id).order("id").last
  end

  def to_next
    SupplierInvoice.where("id > ?", id).order("id").first
  end

  def to_last
    SupplierInvoice.order("id").last
  end

  private

  def check_for_dependent_records
    # Check for supplier payments
    if supplier_payments.count > 0
      errors.add(:base, I18n.t('activerecord.models.receipt_note.check_for_supplier_payments'))
      return false
    end
  end
end
