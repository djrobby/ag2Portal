class SupplierInvoice < ActiveRecord::Base
  belongs_to :supplier
  belongs_to :payment_method
  belongs_to :project
  belongs_to :work_order
  belongs_to :charge_account
  belongs_to :organization
  belongs_to :receipt_note
  attr_accessible :discount, :discount_pct, :invoice_date, :invoice_no, :remarks,
                  :supplier_id, :payment_method_id, :project_id, :work_order_id, :charge_account_id,
                  :posted_at, :organization_id, :receipt_note_id

  has_many :supplier_invoice_items, dependent: :destroy
  has_many :supplier_invoice_approvals, dependent: :destroy
  has_many :supplier_payments

  # Nested attributes
  accepts_nested_attributes_for :supplier_invoice_items,                                 
                                :reject_if => :all_blank,
                                :allow_destroy => true
  accepts_nested_attributes_for :supplier_invoice_approvals,                                 
                                :reject_if => :all_blank,
                                :allow_destroy => true

  has_paper_trail

  validates_associated :supplier_invoice_items, :supplier_invoice_approvals

  validates :invoice_date,   :presence => true
  validates :invoice_no,     :presence => true,
                             :uniqueness => { :scope => [ :organization_id, :supplier_id ] }
  validates :supplier,       :presence => true
  validates :payment_method, :presence => true
  validates :project,        :presence => true
  validates :organization,   :presence => true

  before_destroy :check_for_dependent_records

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = ""
    if !self.invoice_no.blank?
      full_name += self.invoice_no
    end
    if !self.invoice_date.blank?
      full_name += " " + self.invoice_date.to_s
    end
    if !self.supplier.blank?
      full_name += " " + self.supplier.full_name
    end
    full_name
  end

  #
  # Calculated fields
  #
  def subtotal
    subtotal = 0
    supplier_invoice_items.each do |i|
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
    supplier_invoice_items.each do |i|
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
    supplier_invoice_items.sum("quantity")
  end

  def paid
    supplier_payments.sum("amount")
  end
  
  def debt
    total - paid
  end
  
  def payment_avg_date
    avg, cnt = 0, 0
    supplier_payments.each do |i|
      if !i.payment_date.blank?
        avg = Time.parse(i.payment_date.to_s).to_f
        cnt += 1
      end
    end
    cnt > 0 ? Date.parse(Time.at(avg / cnt).to_s) : nil
  end
  
  def payment_period
    (invoice_date - payment_avg_date).to_i rescue 0
  end
  
  def approved_to_pay
    supplier_invoice_approvals.sum("approved_amount")
  end
  
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

  searchable do
    text :invoice_no
    string :invoice_no
    integer :id
    integer :payment_method_id
    integer :project_id
    integer :store_id
    integer :work_order_id
    integer :charge_account_id
    date :invoice_date
    date :posted_at
    integer :organization_id
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
