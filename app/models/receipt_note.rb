class ReceiptNote < ActiveRecord::Base
  belongs_to :supplier
  belongs_to :payment_method
  belongs_to :project
  belongs_to :store
  belongs_to :work_order
  belongs_to :charge_account
  belongs_to :purchase_order
  belongs_to :organization
  attr_accessible :discount, :discount_pct, :receipt_date, :receipt_no, :remarks, :retention_pct, :retention_time,
                  :supplier_id, :payment_method_id, :project_id, :store_id, :work_order_id, :charge_account_id,
                  :purchase_order_id, :organization_id

  has_many :receipt_note_items, dependent: :destroy
  has_many :supplier_invoice_items

  # Nested attributes
  accepts_nested_attributes_for :receipt_note_items,                                 
                                :reject_if => :all_blank,
                                :allow_destroy => true

  has_paper_trail

  validates_associated :receipt_note_items

  validates :receipt_date,    :presence => true
  validates :receipt_no,      :presence => true,
                              :uniqueness => { :scope => [ :organization_id, :supplier_id ] }
  validates :supplier,        :presence => true
  validates :payment_method,  :presence => true
  validates :project,         :presence => true
  validates :organization,    :presence => true

  before_destroy :check_for_dependent_records

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = ""
    if !self.receipt_no.blank?
      full_name += self.receipt_no
    end
    if !self.receipt_date.blank?
      full_name += " " + self.receipt_date.to_s
    end
    if !self.supplier.blank?
      full_name += " " + self.supplier.full_name
    end
    full_name
  end

  def partial_name
    partial_name = ""
    if !self.receipt_no.blank?
      partial_name += self.receipt_no
    end
    if !self.supplier.blank?
      partial_name += " " + self.supplier.full_name
    end
    partial_name
  end

  #
  # Calculated fields
  #
  def subtotal
    subtotal = 0
    receipt_note_items.each do |i|
      if !i.amount.blank?
        subtotal += i.amount
      end
    end
    subtotal
  end

  def bonus
    (discount_pct / 100) * subtotal if !discount_pct.blank?
  end
  
  def taxable
    subtotal - bonus - discount
  end

  def taxes
    taxes = 0
    receipt_note_items.each do |i|
      if !i.net_tax.blank?
        taxes += i.net_tax
      end
    end
    taxes
  end

  def total
    taxable + taxes  
  end

  def quantity
    receipt_note_items.sum("quantity")
  end

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

  searchable do
    text :receipt_no
    string :receipt_no
    integer :id
    integer :payment_method_id
    integer :project_id, :multiple => true
    integer :store_id
    integer :work_order_id
    integer :charge_account_id
    integer :supplier_id
    integer :purchase_order_id
    date :receipt_date
    integer :organization_id
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
