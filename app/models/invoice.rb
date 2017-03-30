class Invoice < ActiveRecord::Base
  belongs_to :bill
  belongs_to :invoice_status
  belongs_to :invoice_type
  belongs_to :invoice_operation
  belongs_to :tariff_scheme
  belongs_to :biller, :class_name => 'Company'
  belongs_to :billing_period
  belongs_to :charge_account
  belongs_to :organization
  belongs_to :payment_method
  belongs_to :sale_offer, :counter_cache => true

  alias_attribute :company, :biller

  attr_accessible :invoice_no, :invoice_date, :consumption, :consumption_real, :consumption_estimated, :consumption_other,
                  :discount_pct, :exemption, :payday_limit,
                  :bill_id, :invoice_status_id, :invoice_type_id, :tariff_scheme_id, :invoice_operation_id,
                  :biller_id, :original_invoice_id, :billing_period_id, :charge_account_id,
                  :created_by, :updated_by, :reading_1_date, :reading_2_date, :reading_1_index, :reading_2_index,
                  :remarks, :organization_id, :payment_method_id, :sale_offer_id, :totals
  attr_accessible :invoice_items_attributes

  has_many :invoice_items, dependent: :destroy
  has_many :client_payments
  has_one :pre_invoice
  has_one :invoice_debt
  has_one :invoice_bill
  has_one :invoice_credit
  has_one :invoice_rebill
  has_one :active_invoice
  has_one :cancelled_invoice
  has_one :active_supply_invoice

  # Nested attributes
  accepts_nested_attributes_for :invoice_items,
                                :reject_if => :all_blank,
                                :allow_destroy => true

  # Self join
  has_many :credits_rebills, class_name: 'Invoice', foreign_key: 'original_invoice_id'
  belongs_to :original_invoice, :class_name => 'Invoice'

  has_paper_trail

  validates_associated :invoice_items

  validates :invoice_no,      :presence => true,
                              :length => { :is => 16 },
                              :format => { with: /\A[a-zA-Z\d]+\Z/, message: :code_invalid },
                              :uniqueness => { :scope => :organization_id }
  validates :invoice_date,    :presence => true
  validates :organization,    :presence => true
  validates :invoice_status,  :presence => true
  validates :invoice_type,    :presence => true

  # Scopes
  scope :by_no, -> { order(:invoice_no) }
  #
  scope :commercial, -> { where("invoice_type_id != 1 AND invoice_type_id != 3").by_no }
  scope :service, -> { where("invoice_type_id = 1").by_no }
  scope :contracting, -> { where("invoice_type_id = 3").by_no }

  # Callbacks
  before_validation :item_repeat, :on => :create
  before_save :calculate_and_store_totals
  before_create :assign_payday_limit
  after_save :bill_status

  def discount_zero?
    invoice_items.map(&:discount).all?{|d| d==0}
  end

  def discount_pct_zero?
    invoice_items.map(&:discount_pct).all?{|d| d==0}
  end

  def total_by_concept(billable_concept=1, includes_cf=false)
    if includes_cf
      invoice_items.joins(tariff: :billable_item).where('billable_items.billable_concept_id = ?', billable_concept.to_i).sum(&:amount)
    else
      invoice_items.joins(tariff: :billable_item).where('billable_items.billable_concept_id = ? AND subcode != "CF"', billable_concept.to_i).sum(&:amount)
    end
  end

  def total_by_invoice_concept(billable_concept)
    invoice_items.flatten.select{|item| item.tariff.billable_item.billable_concept_id == billable_concept.to_i}.sum(&:amount)
  end

  def full_no
    # Invoice no (Invoice code & year & sequential number) => SSSSS-YYYY-NNNNNNN
    invoice_no.blank? ? "" : invoice_no[0..4] + '-' + invoice_no[5..8] + '-' + invoice_no[9..15]
  end

  def invoiced_concepts
    _codes = ""
    _ii = invoice_items.group(:code)
    _ii.each do |r|
      if _codes == ""
        _codes += r.code
      else
        _codes += ("-" + r.code)
      end
    end
    _codes
  end

  def invoiced_subtotals_by_concept
    _codes = []
    _aux = []
    _ii = invoice_items.group(:tariff_id)
    _ii.each do |r|
      _aux = _aux << r.tariff.billable_concept.id
      _aux = _aux << r.tariff.billable_concept.name
      _aux = _aux << invoice_items.where(tariff_id: r.tariff_id).sum(&:amount)
      _codes = _codes << _aux
      _aux = []
    end
    _codes
  end

  def client
    bill.client unless (bill.blank? || bill.client.blank?)
  end

  #
  # Calculated fields
  #
  def item_discount_present?
    present = false
    invoice_items.each do |i|
      if i.discount_present?
        present = true
        break
      end
    end
    present
  end

  def unpaid?
    if payday_limit.nil?
      false
    else
      payday_limit < Date.today
    end
  end

  def reading_1
    bill.reading_1
  end

  def reading_2
    bill.reading_2
  end

  def reading_1_id
    bill.try(:reading_1).try(:id)
  end

  def reading_2_id
    bill.try(:reading_2).try(:id)
  end

  def tax_breakdown
    invoice_items.group_by{|i| i.tax_type_id}.map do |t|
      tax = t[0].nil? ? 0 : TaxType.find(t[0]).tax
      sum_total = t[1].sum{|invoice_item| invoice_item.amount}
      tax_total = sum_total * (tax/100)
      description = t[0].nil? ? 0 : TaxType.find(t[0]).description
      [tax, sum_total, tax_total ,t[1].count, description]
    end
  end

  def breakdown
    invoice_items.group_by{|i| i.tax_type_id}.map do |t|
      tax = t[0].nil? ? nil : TaxType.find(t[0])
      sum_total = t[1].sum{|j| j.amount}
      tax_total = sum_total * (tax/100)
      [tax.try(:id), sum_total, tax_total ,t[1].count]
    end
  end

  def net_tax
    tax_breakdown.sum{|t| t[2]}
  end

  def subtotal
    tax_breakdown.sum{|t| t[1]}
  end

  def bonus
    (discount_pct / 100) * subtotal
  end

  def taxable
    subtotal - bonus
  end

  def taxes
    tax_breakdown.sum{|t| t[2]}
  end

  def total
    (taxes + taxable).truncate(4)
  end

  def receivable
    total - exemption
  end

  def collected
    client_payments.sum(:amount)
  end

  def debt
    receivable - collected
  end

  def quantity
    invoice_items.sum(:quantity)
  end

  searchable do
    text :invoice_no
    # text :client_code_name_fiscal do
    #   bill.client.full_name_or_company_code_fiscal unless (bill.blank? || bill.client.blank?)
    # end
    # text :subscriber_code_name_address_fiscal do
    #   bill.subscriber.code_full_name_or_company_address_fiscal unless (bill.blank? || bill.subscriber.blank?)
    # end
    string :client_code_name_fiscal, :multiple => true do
      bill.client.full_name_or_company_code_fiscal unless (bill.blank? || bill.client.blank?)
    end
    string :subscriber_code_name_address_fiscal, :multiple => true do
      bill.subscriber.code_full_name_or_company_address_fiscal unless (bill.blank? || bill.subscriber.blank?)
    end
    string :invoice_no, :multiple => true   # Multiple search values accepted in one search (inverse_no_search)
    integer :id
    integer :original_invoice_id
    integer :bill_id
    integer :invoice_status_id
    integer :invoice_type_id
    integer :invoice_operation_id
    integer :tariff_scheme_id
    integer :biller_id
    integer :billing_period_id
    integer :charge_account_id
    date :invoice_date
    integer :client_id do
      bill.client_id unless (bill.blank? || bill.client_id.blank?)
    end
    integer :subscriber_id do
      bill.subscriber_id unless (bill.blank? || bill.subscriber_id.blank?)
    end
    integer :project_id do
      bill.project_id unless (bill.blank? || bill.project_id.blank?)
    end
    string :sort_no do
      invoice_no
    end
    integer :organization_id
    integer :payment_method_id
  end

  private

  def calculate_and_store_totals
    self.totals = total
  end

  def item_repeat
    @errors.add(:base, "Invoice repeat") if !Invoice.where(bill_id: bill_id, invoice_type_id: invoice_type_id, invoice_operation_id: invoice_operation_id, billing_period_id: billing_period_id, biller_id: biller_id).blank?
  end

  def bill_status
    b = self.bill rescue nil
    b.update_attributes(invoice_status_id: b.invoices.map(&:invoice_status_id).min) unless b.nil?
  end

  def assign_payday_limit
    self.payday_limit = self.invoice_date if self.payday_limit.nil?
  end
end
