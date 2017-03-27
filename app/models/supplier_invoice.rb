class SupplierInvoice < ActiveRecord::Base
  include ModelsModule

  belongs_to :supplier
  belongs_to :payment_method
  belongs_to :project
  belongs_to :work_order
  belongs_to :charge_account
  belongs_to :organization
  belongs_to :receipt_note
  belongs_to :purchase_order
  attr_accessible :discount, :discount_pct, :invoice_date, :invoice_no, :remarks,
                  :supplier_id, :payment_method_id, :project_id, :work_order_id, :charge_account_id,
                  :posted_at, :organization_id, :receipt_note_id, :purchase_order_id, :attachment,
                  :internal_no, :withholding, :totals
  attr_accessible :supplier_invoice_items_attributes, :supplier_invoice_approvals_attributes
  has_attached_file :attachment, :styles => { :medium => "192x192>", :small => "128x128>" }, :default_url => "/images/missing/:style/attachment.png"

  has_many :supplier_invoice_items, dependent: :destroy
  has_many :supplier_invoice_approvals, dependent: :destroy
  has_many :products, through: :supplier_invoice_items
  has_many :supplier_payments
  has_one :supplier_invoice_debt

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
  validates :internal_no,    :uniqueness => { :scope => :project_id }, :if => "!internal_no.nil?"

  # Callbacks
  before_destroy :check_for_dependent_records
  before_save :calculate_and_store_totals
  after_create :notify_on_create
  after_update :notify_on_update

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = ""
    if !self.invoice_no.blank?
      full_name += self.invoice_no
    end
    if !self.invoice_date.blank?
      full_name += " " + formatted_date(self.invoice_date)
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
    supplier_invoice_items.reject(&:marked_for_destruction?).sum(&:amount)
  end

  def bonus
    (discount_pct / 100) * subtotal if !discount_pct.blank?
  end

  def taxable
    subtotal - bonus - discount
  end

  def taxes
    supplier_invoice_items.reject(&:marked_for_destruction?).sum(&:net_tax)
  end

  def total
    taxable + taxes
  end

  def quantity
    supplier_invoice_items.sum(:quantity)
  end

  def paid
    supplier_payments.sum(:amount)
  end

  def debt
    total - paid
  end

  def payment_avg_date
    avg, cnt = 0, 0
    supplier_payments.each do |i|
      if !i.payment_date.blank?
        avg += Time.parse(i.payment_date.to_s).to_f
        cnt += 1
      end
    end
    cnt > 0 ? Date.parse(Time.at(avg / cnt).to_s) : nil
  end

  def payment_period
    (invoice_date - payment_avg_date).to_i rescue 0
  end

  def approved_to_pay
    supplier_invoice_approvals.sum(:approved_amount)
  end

  def amount_not_yet_approved
    total - approved_to_pay
  end

  #
  # Records navigator
  #
  def to_first
    SupplierInvoice.order("id desc").first
  end

  def to_prev
    SupplierInvoice.where("id > ?", id).order("id desc").last
  end

  def to_next
    SupplierInvoice.where("id < ?", id).order("id desc").first
  end

  def to_last
    SupplierInvoice.order("id desc").last
  end

  searchable do
    text :invoice_no
    string :invoice_no, :multiple => true   # Multiple search values accepted in one search (inverse_no_search)
    integer :id
    integer :supplier_id
    integer :payment_method_id
    integer :project_id, :multiple => true
    integer :work_order_id
    integer :charge_account_id
    date :invoice_date
    date :posted_at
    integer :organization_id
  end

  private

  def calculate_and_store_totals
    self.totals = total
  end

  def check_for_dependent_records
    # Check for supplier payments
    if supplier_payments.count > 0
      errors.add(:base, I18n.t('activerecord.models.receipt_note.check_for_supplier_payments'))
      return false
    end
  end

  #
  # Notifiers
  #
  # After create
  def notify_on_create
    # Always notify on create
    Notifier.supplier_invoice_saved(self, 1).deliver
    Notifier.supplier_invoice_saved_with_approval(self, 1).deliver
  end

  # After update
  def notify_on_update
    # Always notify on update
    Notifier.supplier_invoice_saved(self, 3).deliver
    if check_if_approval_is_required
      Notifier.supplier_invoice_saved_with_approval(self, 3).deliver
    end
  end

  #
  # Helper methods for notifiers
  #
  # Need approval?
  def check_if_approval_is_required
    # should not notify if only approvals were changed
    _r = false
    if self.changed?
      _r = true
    end
    _r
  end
end
