class Invoice < ActiveRecord::Base
  # Pending status
  # PENDING: invoice_status_id == 1
  # UNPAID: invoice_status_id == 1 AND payday_limit < Date.today
  # CLAIMED: invoice_status_id == 1 AND payday_limit < Date.today AND debt_claim_items.size > 0

  include ModelsModule

  @@block_codes = ["BL1", "BL2", "BL3", "BL4", "BL5", "BL6", "BL7", "BL8"]
  @@no_block_codes = ["CF", "CV", "VP"]

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
                  :remarks, :organization_id, :payment_method_id, :sale_offer_id, :old_no,
                  :totals, :receivables, :total_taxes
  attr_accessible :invoice_items_attributes

  has_many :invoice_items, dependent: :destroy
  has_many :client_payments
  has_one :pre_invoice
  has_one :invoice_debt
  has_one :invoice_current_debt
  has_one :invoice_bill
  has_one :invoice_credit
  has_one :invoice_rebill
  has_one :active_invoice
  has_one :cancelled_invoice
  has_one :active_supply_invoice
  has_many :debt_claim_items

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
  scope :by_id, -> { order(:id) }
  #
  scope :unpaid, -> { where("invoice_status_id = 1 AND payday_limit < ?", Date.today).by_id }
  scope :unpaid_and_unclaimed, -> {
    joins('LEFT JOIN debt_claim_items ON invoices.id=debt_claim_items.invoice_id')
    .where('debt_claim_items.invoice_id IS NULL AND invoices.invoice_status_id = 1 AND invoices.payday_limit < ?', Date.today).by_id
  }
  scope :unpaid_and_claimed, -> {
    joins(:debt_claim_items).where('invoices.invoice_status_id = 1 AND invoices.payday_limit < ?', Date.today).by_id
  }
  scope :unclaimed, -> {
    joins('LEFT JOIN debt_claim_items ON invoices.id=debt_claim_items.invoice_id')
    .where('debt_claim_items.invoice_id IS NULL').by_id
  }
  scope :claimed, -> { joins(:debt_claim_items).by_id }
  #
  scope :commercial, -> { where("invoice_type_id != 1 AND invoice_type_id != 3").by_no }
  scope :service, -> { where(invoice_type_id: InvoiceType::WATER).by_no }
  scope :contracting, -> { where(invoice_type_id: InvoiceType::CONTRACT).by_no }
  scope :g_where, -> w {
    joins(:bill)
    .where(w)
    .by_no
  }
  scope :by_bill_ids, -> i {
    where("invoices.bill_id IN (#{i})")
    .select("invoices.*")
    .group('invoices.id').order('invoices.id DESC')
  }

  # Callbacks
  before_save :calculate_and_store_totals
  before_validation :item_repeat, :on => :create
  before_create :assign_payday_limit
  after_save :bill_status

  #
  # Methods
  #
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

  def total_by_concept_ff(billable_concept=1)
    invoice_items.joins(tariff: :billable_item).where('billable_items.billable_concept_id = ? AND subcode = "CF"', billable_concept.to_i).sum(&:amount)
  end

  def total_by_invoice_concept(billable_concept)
    invoice_items.flatten.select{|item| item.tariff.billable_item.billable_concept_id == billable_concept.to_i}.sum(&:amount)
  end

  def full_no
    # Invoice no (Invoice code & office & year & sequential number) => SSSOO-YYYY-NNNNNNN
    invoice_no.blank? ? "" : invoice_no[0..4] + '-' + invoice_no[5..8] + '-' + invoice_no[9..15]
  end

  # Old program No
  def old_no_based_real_no
    old_no.blank? ? full_no : old_no
  end

  def formatted_payday_limit
    formatted_date(payday_limit) rescue ''
  end

  def formatted_biller_name
    biller_name || ''
  end

  def formatted_biller_fiscal_id
    biller_fiscal_id || ''
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

  def ordered_invoiced_concepts
    _codes = []
    _prev_code = invoice_items.first.code
    _amount = 0
    _description = ''
    invoice_items.each do |i|
      if i.code != _prev_code
        _codes << [_prev_code, _description, _amount]
        _prev_code = i.code
        _amount = 0
      end
      _description = i.description[0] == '0' || i.description[0] == '1' ? i.description[1..-1] : i.description
      _amount += i.amount
    end
    _codes << [_prev_code, _description, _amount]
    _codes
  end

  def invoice_items_by_concept(_code='SUM')
    invoice_items.includes(:tariff, :tax_type, :measure).where(code: _code).order(:id)
  end

  def block_items(_items = invoice_items)
    _items.select {|i| @@block_codes.include? i.subcode}
  end

  def no_block_items(_items = invoice_items)
    _items.select {|i| @@no_block_codes.include? i.subcode}
  end

  def has_block_items?(_items = invoice_items)
    present = false
    _items.each do |i|
      if i.is_block?
        present = true
        break
      end
    end
    present
  end

  def block_item_tariffs(_items = invoice_items)
    _tariffs = []
    _prev_tariff = 0
    _items.each do |i|
      if i.tariff_id != _prev_tariff
        _tariffs << [i.tariff_id, i.tariff_starting_at, i.tariff_ending_at, i.description[0]]
        _prev_tariff = i.tariff_id
      end
    end
    _tariffs
  end

  # Array of:
  # [0] concept.code
  # [1] regulation_id
  def regulations(_items = invoice_items.includes(tariff: :billable_item).order(:id))
    _i = nil
    _codes = []
    _aux = []
    _items.each do |i|
      _i = i.regulation
      if !_i.blank?
        unless _aux.include? i.regulation
          _aux << _i
          _codes << i.code
        end
      end
    end
    _codes.zip(_aux)
  end

  # Returns
  # [0] billable_concept.id
  # [1] billable_concept.name
  # [2] invoice_items.sum(amount) grouped by billable_concept
  # [3] 0=previous tariff, 1=current tariff, nil=not prorated
  # [4] billable_item.regulation_id
  def invoiced_subtotals_by_concept
    _codes = []
    _aux = []
    _ii = invoice_items.joins(tariff: :billable_item).order('billable_items.billable_concept_id').group('billable_items.billable_concept_id')
    _ii.each do |r|
      _aux = _aux << r.tariff.billable_concept.id
      _aux = _aux << r.tariff.billable_concept.name
      _aux = _aux << invoice_items.where(code: r.tariff.billable_concept.code).sum(&:amount)
      if r.description[0] == 0.to_s || r.description[0] == 1.to_s
        _aux = _aux << r.description[0]
      else
        _aux = _aux << nil
      end
      _aux = _aux << r.tariff.billable_item.regulation_id
      _codes = _codes << _aux
      _aux = []
    end
    _codes
  end

  # Same as 'invoiced_subtotals_by_concept', but when items are prorated (different tariffs, two items by each concept)
  # Returns
  # [0] billable_concept.id
  # [1] billable_concept.name
  # [2] invoice_items.sum(amount) grouped by billable_item
  # [3] billable_concept.code
  # [4] 0=previous tariff, 1=current tariff, nil=not prorated
  # [5] billable_item.regulation_id
  # [6] billable_item.id
  # [7] tariff.id
  def invoiced_subtotals_by_billable_item
    _codes = []
    _aux = []
    _ii = invoice_items.joins(tariff: :billable_item).order('billable_items.billable_concept_id').group('billable_item_id')
    _ii.each do |r|
      _aux = _aux << r.tariff.billable_concept.id
      _aux = _aux << r.tariff.billable_concept.name
      _aux = _aux << invoice_items.joins(:tariff).where('tariffs.billable_item_id=?', r.tariff.billable_item_id).sum(&:amount)
      _aux = _aux << r.code
      if r.description[0] == 0.to_s || r.description[0] == 1.to_s
        _aux = _aux << r.description[0]
      else
        _aux = _aux << nil
      end
      _aux = _aux << r.tariff.billable_item.regulation_id
      _aux = _aux << r.tariff.billable_item_id
      _aux = _aux << r.tariff_id
      _codes = _codes << _aux
      _aux = []
    end
    _codes
  end

  def bill_no
    bill.bill_no unless (bill.blank? || bill.bill_no.blank?)
  end

  def project
    bill.project unless (bill.blank? || bill.project.blank?)
  end

  def office
    bill.office unless bill.blank?
  end

  def company
    bill.company unless bill.blank?
  end

  def client
    bill.client unless (bill.blank? || bill.client.blank?)
  end

  def subscriber
    bill.subscriber unless (bill.blank? || bill.subscriber.blank?)
  end

  def biller_name
    biller.name unless (biller.blank? || biller.name.blank?)
  end

  def biller_fiscal_id
    biller.fiscal_id unless (biller.blank? || biller.fiscal_id.blank?)
  end

  def invoice_type_name
    invoice_type.name rescue ''
  end

  def invoice_type_code
    invoice_type.code rescue ''
  end

  def invoice_type_by_item_description
    invoice_items.first.description.capitalize rescue ''
  end

  def invoice_status_code
    invoice_status.code rescue ''
  end

  def invoice_operation_code
    invoice_operation.code rescue ''
  end

  def payment_date
    formatted_date(client_payments.last.payment_date) rescue ''
  end

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
    if invoice_status_id == InvoiceStatus::PENDING && !payday_limit.nil?
      payday_limit < Date.today
    else
      false
    end
  end

  def claimed?
    !debt_claim_items.empty?
  end

  def claims_count
    debt_claim_items.size
  end
  def claim_ids
    debt_claim_items.map(&:id)
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

  #
  # Calculated fields
  #
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
    totals - exemption
  end

  def collected
    client_payments.sum(:amount)
  end

  def debt
    receivables - collected
  end

  def quantity
    invoice_items.sum(:quantity)
  end

  # Calculates & returns the average billed consumption up to the last six invoices
  def average_billed_consumption
    _prev_consumptions = []
    _average_consumption = 0
    if !billing_period.blank? && invoice_type_id == InvoiceType::WATER
      ii = ActiveSupplyInvoice.joins(:billing_period).where('period <= ? AND subscriber_id = ?', billing_period.period, subscriber.id).order('period DESC').first(6)
      if !ii.blank?
        ii.each do |_i|
          _prev_consumptions << _i.invoice.consumption
          _average_consumption += _i.invoice.consumption
        end
        _average_consumption = _average_consumption / ii.count
      end
    end
    return _prev_consumptions, _average_consumption
  end

  searchable do
    text :invoice_no
    integer :organization_id
    integer :payment_method_id
    # text :client_code_name_fiscal do
    #   bill.client.full_name_or_company_code_fiscal unless (bill.blank? || bill.client.blank?)
    # end
    # text :subscriber_code_name_address_fiscal do
    #   bill.subscriber.code_full_name_or_company_address_fiscal unless (bill.blank? || bill.subscriber.blank?)
    # end
    string :client_code_name_fiscal, :multiple => true do
      bill.client.full_name_or_company_code_fiscal unless (bill.blank? || bill.client.blank?)
    end
    string :subscriber_code_name_fiscal, :multiple => true do
      bill.subscriber.code_full_name_or_company_fiscal unless (bill.blank? || bill.subscriber.blank?)
    end
    string :supply_address, :multiple => true do
      bill.subscriber.subscriber_supply_address.supply_address unless (bill.subscriber.blank? || bill.subscriber.subscriber_supply_address.blank? || bill.subscriber.subscriber_supply_address.supply_address.blank?)
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
    date :payday_limit
    integer :client_id do
      bill.client_id unless (bill.blank? || bill.client_id.blank?)
    end
    integer :subscriber_id do
      bill.subscriber_id unless (bill.blank? || bill.subscriber_id.blank?)
    end
    integer :project_id, :multiple => true do
      bill.project_id unless (bill.blank? || bill.project_id.blank?)
    end
    string :sort_no do
      invoice_no
    end
  end

  private

  def calculate_and_store_totals
    self.totals = total
    self.receivables = receivable
    self.total_taxes = taxes
  end

  def item_repeat
    @errors.add(:base, "Invoice repeat") if !Invoice.where(bill_id: bill_id, invoice_type_id: invoice_type_id, invoice_operation_id: invoice_operation_id, billing_period_id: billing_period_id, biller_id: biller_id).blank?
  end

  def bill_status
    b = self.bill rescue nil
    b.update_attributes(invoice_status_id: b.invoices.select('min(invoice_status_id) as min_status').first.min_status) unless b.nil?
  end

  def assign_payday_limit
    self.payday_limit = self.invoice_date if self.payday_limit.nil?
    true
  end
end
