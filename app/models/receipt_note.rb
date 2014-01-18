class ReceiptNote < ActiveRecord::Base
  belongs_to :supplier
  belongs_to :payment_method
  belongs_to :project
  belongs_to :store
  belongs_to :work_order
  belongs_to :charge_account
  attr_accessible :discount, :discount_pct, :receipt_date, :receipt_no, :remarks, :retention_pct, :retention_time,
                  :supplier_id, :payment_method_id, :project_id, :store_id, :work_order_id, :charge_account_id

  has_many :receipt_note_items, dependent: :destroy
  has_many :supplier_invoice_items

  has_paper_trail

  validates :receipt_date,   :presence => true
  validates :receipt_no,     :presence => true
  validates :supplier,       :presence => true
  validates :payment_method, :presence => true

  before_destroy :check_for_dependent_records

  #
  # Records navigator
  #
  def to_first
    ReceiptNote.order("id").first
  end

  def to_prev
    ReceiptNote.where("id < ?", id).order("id").last
  end

  def to_next
    ReceiptNote.where("id > ?", id).order("id").first
  end

  def to_last
    ReceiptNote.order("id").last
  end

  private

  def check_for_dependent_records
    # Check for supplier invoice items
    if supplier_invoice_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.receipt_note.check_for_supplier_invoices'))
      return false
    end
  end
end
