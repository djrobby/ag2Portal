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

  # Scopes
  scope :by_no, -> { order(:invoice_no) }
  scope :by_date, -> { order(:invoice_date) }
  scope :by_created_at, -> { order(:created_at) }

  # Callbacks
  before_destroy :check_for_dependent_records
  before_save :calculate_and_store_totals # must include withholding to negative
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
    taxable + taxes + withholding
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
  # Class (self) user defined methods
  #
  def self.to_csv(array)
    column_names = [I18n.t('activerecord.csv_sage200.supplier_invoice.c001'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c002'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c003'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c004'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c005'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c006'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c007'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c008'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c009'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c010'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c011'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c012'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c013'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c014'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c015'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c016'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c017'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c018'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c019'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c020'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c021'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c022'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c023'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c024'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c025'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c026'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c027'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c028'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c029'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c030'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c031'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c032'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c033'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c034'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c035'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c036'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c037'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c038'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c039'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c040'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c041'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c042'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c043'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c044'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c045'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c046'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c047'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c048'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c049'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c050'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c051'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c052'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c053'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c054'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c055'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c056'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c057'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c058'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c059'),
                    I18n.t('activerecord.csv_sage200.supplier_invoice.c060')]
    CSV.generate(headers: true) do |csv|
      csv << column_names
      array.each do |i|
        csv << ['1',  # 001
                '2017',  # 002
                '1',  # 003
                'D',  # 004
                nil,  # 005
                nil,  # 006
                nil,  # 007
                nil,  # 008
                nil,  # 009
                nil,  # 010
                nil,  # 011
                nil,  # 012
                nil,  # 013
                nil,  # 014
                nil,  # 015
                nil,  # 016
                nil,  # 017
                nil,  # 018
                nil,  # 019
                nil,  # 020
                nil,  # 021
                nil,  # 022
                nil,  # 023
                nil,  # 024
                nil,  # 025
                nil,  # 026
                nil,  # 027
                nil,  # 028
                nil,  # 029
                nil,  # 030
                nil,  # 031
                nil,  # 032
                nil,  # 033
                nil,  # 034
                nil,  # 035
                nil,  # 036
                nil,  # 037
                nil,  # 038
                nil,  # 039
                nil,  # 040
                nil,  # 041
                nil,  # 042
                nil,  # 043
                nil,  # 044
                nil,  # 045
                nil,  # 046
                nil,  # 047
                nil,  # 048
                nil,  # 049
                nil,  # 050
                nil,  # 051
                nil,  # 052
                nil,  # 053
                nil,  # 054
                nil,  # 055
                nil,  # 056
                nil,  # 057
                nil,  # 058
                nil,  # 059
                nil]  # 060
      end # array.each
    end # CSV.generate
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
    self.withholding = self.withholding * (-1) if self.withholding > 0
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
