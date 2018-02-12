class Bill < ActiveRecord::Base
  include ModelsModule

  belongs_to :organization
  belongs_to :payment_method
  belongs_to :project
  belongs_to :invoice_status
  belongs_to :subscriber
  belongs_to :client
  belongs_to :street_type
  belongs_to :zipcode
  belongs_to :town
  belongs_to :province
  belongs_to :region
  belongs_to :country
  belongs_to :reading_1, :class_name => 'Reading' # Previous reading
  belongs_to :reading_2, :class_name => 'Reading' # Current reading
  # About readings: Consumption = reading_2.reading_index - reading_1.reading_index

  attr_accessible :bill_date, :bill_no, :first_name, :last_name, :company, :fiscal_id,
                  :project_id, :invoice_status_id, :subscriber_id, :client_id,
                  :street_type_id, :street_name, :street_number, :building, :floor, :floor_office,
                  :zipcode_id, :town_id, :province_id, :region_id, :country_id, :created_by, :updated_by,
                  :reading_1_id, :reading_2_id, :organization_id, :payment_method_id, :old_no

  has_many :invoices, dependent: :destroy
  has_many :invoice_items, through: :invoices
  has_many :client_payments
  has_many :instalments
  has_one :pre_bill
  has_many :cancelled_invoices
  has_many :active_invoices
  has_many :active_supply_invoices
  has_many :invoice_current_debts
  # Contract bill for: New contracting or change of holder (to NEW subscriber)
  has_one :water_supply_contract
  has_one :water_connection_contract
  # Service bill for: Change of holder or unsubscribe (to OLD subscriber, meter withdrawal)
  has_one :unsubscribe_water_supply_contract, :class_name => 'WaterSupplyContract', foreign_key: "unsubscribe_bill_id"
  # Contract bill for: Change of holder or unsubscribe (return of deposit to OLD subscriber)
  has_one :bailback_water_supply_contract, :class_name => 'WaterSupplyContract', foreign_key: "bailback_bill_id"

  validates :bill_no,         :presence => true,
                              :length => { :is => 23 },
                              :format => { with: /\A[a-zA-Z\d]+\Z/, message: :code_invalid },
                              :uniqueness => { :scope => :organization_id }
  validates :bill_date,       :presence => true
  validates :organization,    :presence => true
  validates :project,         :presence => true
  validates :client,          :presence => true

  # Scopes
  scope :by_no, -> { order(:bill_no) }
  #
  scope :none, where("1 = 0")
  scope :commercial, -> { joins(:invoices).where("invoices.invoice_type_id != ? AND invoices.invoice_type_id != ?", InvoiceType::WATER, InvoiceType::CONTRACT).by_no }
  scope :contracting, -> { joins(:invoices).where(invoices: {invoice_type_id: InvoiceType::CONTRACT}).by_no }
  scope :not_service, -> { joins(:invoices).where("invoices.invoice_type_id != ?", InvoiceType::WATER).by_no }
  scope :service, -> { joins(:invoices).where(invoices: {invoice_type_id: InvoiceType::WATER}).by_no }
  scope :service_by_project_period, -> p, b {
    joins(:invoices)
    .where('invoices.invoice_type_id = ? AND bills.project_id = ? AND invoices.billing_period_id = ?', InvoiceType::WATER, p, b)
    .by_no
  }
  scope :service_by_project_period_no, -> p, b, f, t {
    joins(:invoices)
    .where('invoices.invoice_type_id = ? AND bills.project_id = ? AND invoices.billing_period_id = ? AND bills.bill_no BETWEEN ? AND ?', InvoiceType::WATER, p, b, f, t)
    .by_no
  }
  scope :g_where, -> w {
    joins(:invoices)
    .where(w)
    .by_no
  }
  scope :by_subscriber_full, -> s, t {
    joins(:invoice_status, invoices: [:invoice_type, :invoice_operation, [invoice_items: :tax_type]])
    .where("bills.subscriber_id = ? AND bills.invoice_status_id IN (#{t})", s)
  }

  def to_label
    full_no
  end

  # Formal No
  def full_no
    # Bill no (Project code & year & sequential number) => PPPPPPPPPPPP-YYYY-NNNNNNN
    if bill_no == "$err"
      "000000000000-0000-0000000"
    else
      bill_no.blank? ? "" : bill_no[0..11] + '-' + bill_no[12..15] + '-' + bill_no[16..22]
    end
  end

  # 10 digits Id for bank orders
  def full_id
    self.id.blank? ? '0000000000' : self.id.to_s.rjust(10,'0')
  end

  # First invoice no. (own, service)
  def real_no
    invoices.first.full_no rescue full_no
  end
  # 16 characters unformatted invoice_no
  def real_no_unformatted
    invoices.first.invoice_no rescue bill_no.last(16)
  end

  # Old program No
  def invoice_based_old_no
    invoices.first.old_no rescue old_no
  end
  def old_no_based_real_no
    invoice_based_old_no.blank? ? real_no : invoice_based_old_no
  end

  # Short No
  def short_no
    # Bill no (Project ID & year & sequential number) => PPPP-YYYY-NNNNNNN
    code = "0000-0000-0000000"
    if bill_no != "$err" && !bill_no.blank? && !project_id.blank?
      code = project_id.to_s.rjust(4, '0') + '-' + bill_no[12..15] + '-' + bill_no[16..22]
    end
    code
  end

  def nullable?
    # (bill_operation == 1 or bill_operation == 3) and Invoice.where(original_invoice_id: invoices.try(:first).try(:id)).blank?
    (bill_operation == 1 || bill_operation == 3) && ((!bill_type.blank? && bill_type.id == InvoiceType::WATER) ? reading.try(:bill_id) == id : true)
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
    invoices.map(&:invoice_items).flatten.select{|item| item.tariff.billable_item.billable_concept_id == billable_concept.to_i}.sum(&:amount)
  end

  def bill_operation
    try(:invoices).try(:first).try(:invoice_operation_id)
  end

  def bill_period
    try(:invoices).try(:first).try(:billing_period_id)
  end

  def billing_period
    invoices.first.billing_period.to_label rescue ''
  end

  def billing_period_code
    invoices.first.billing_period.period.to_s rescue ''
  end

  def bill_type
    invoices.first.invoice_type rescue nil
  end

  def bill_type_id
    invoices.first.invoice_type.id rescue 0
  end

  def company
    project.company unless (project.blank? || project.company.blank?)
  end

  def office
    project.office unless (project.blank? || project.office.blank?)
  end

  def subscriber_supply_address
    subscriber.subscriber_supply_address.supply_address rescue ''
  end

  def reading
    reading_2
  end

  def payday_limit
    invoices.first.payday_limit rescue nil
  end

  def formatted_payday_limit
    invoices.first.formatted_payday_limit
  end

  def payment_date
    formatted_date(client_payments.last.payment_date) rescue ''
  end

  def formatted_reading_1_index
    reading_1.reading_index rescue ''
  end

  def formatted_reading_1_date
    reading_1.formatted_reading_date rescue ''
  end

  def formatted_reading_2_index
    reading_2.reading_index rescue ''
  end

  def formatted_reading_2_date
    reading_2.formatted_reading_date rescue ''
  end

  def issuer
    project.company.numeric_fiscal_id + project.company.first_active_bank_suffix
  end

  def reference
    invoices.first.invoice_no[3..15] rescue ''
  end

  def ident
    if project.company.first_active_bank_suffix < '500'
      subscriber.subscriber_code[5..10]
    else
      invoices.first.payday_limit.strftime("%d%m%y") rescue subscriber.subscriber_code[5..10]
    end
  end

  def consumption
    invoices.first.consumption || 0
  end

  def consumption_real
    invoices.first.consumption_real || 0
  end

  def consumption_estimated
    invoices.first.consumption_estimated || 0
  end

  def consumption_other
    invoices.first.consumption_other || 0
  end

  def average_billed_consumption
    invoices.first.average_billed_consumption[1] || 0
  end

  def previous_billed_consumptions
    invoices.first.average_billed_consumption[0] || []
  end

  # Payment method used in collection
  def real_payment_method_name
    client_payments.last.payment_method.to_label rescue ''
  end
  def real_payment_method_code
    client_payments.last.payment_method.code rescue ''
  end

  # Array of:
  # [0] legend no.
  # [1] concept.code
  # [2] regulation_id
  def regulations
    _codes = []
    _i = 0
    invoices.each do |i|
      i.regulations.each do |r|
        unless _codes.include? r
          _i += 1
          _codes << r.insert(0,_i.to_s)
        end
      end
    end
    _codes
  end

  #
  # Calculated fields
  #
  def total
    invoices.reject(&:marked_for_destruction?).sum(&:totals)
  end

  def receivable
    invoices.reject(&:marked_for_destruction?).sum(&:receivables)
  end

  def collected
    client_payments.sum(:amount)
  end

  def debt
    invoices.reject(&:marked_for_destruction?).sum(&:debt)
  end

  def subtotal
    invoices.reject(&:marked_for_destruction?).sum(&:subtotal)
  end

  def bonus
    invoices.reject(&:marked_for_destruction?).sum(&:bonus)
  end

  def taxes
    invoices.reject(&:marked_for_destruction?).sum(&:taxes)
  end

  def taxable
    invoices.reject(&:marked_for_destruction?).sum(&:taxable)
  end

  def unpaid?
    if !invoices.select{|i| i.payday_limit.nil?}.blank?
      false
    else
      invoices.select{|i| !i.payday_limit.nil?}.all? {|i| i.payday_limit < Date.today}
    end
  end

  def payable?
    invoices.select{|i| !i.payday_limit.nil?}.all? {|i| i.payday_limit > Date.today}
  end

  def sort_id
    self.id
  end

  #
  # Class (self) user defined methods
  #
  def self.without_invoices
    joins('LEFT JOIN invoices ON bills.id=invoices.bill_id').where('invoices.bill_id IS NULL')
  end

  searchable do
    text :bill_no
    date :created_at
    integer :created_by
    integer :organization_id
    integer :payment_method_id
    string :client_code_name_fiscal, :multiple => true do
      client.full_name_or_company_code_fiscal unless client.blank?
    end
    string :subscriber_code_name_fiscal, :multiple => true do
      subscriber.code_full_name_or_company_fiscal unless subscriber.blank?
    end
    string :supply_address, :multiple => true do
      subscriber.subscriber_supply_address.supply_address unless (subscriber.blank? || subscriber.subscriber_supply_address.blank? || subscriber.subscriber_supply_address.supply_address.blank?)
    end
    string :bill_no, :multiple => true   # Multiple search values accepted in one search (inverse_no_search)
    integer :invoice_status_id
    integer :project_id, :multiple => true
    integer :client_id
    integer :subscriber_id
    boolean :bank_account do
      client.active_bank_accounts? unless client.blank?
    end
    integer :billing_period_id do
      reading_2.nil? ? nil : reading_2.billing_period_id
    end
    integer :reading_route_id do
      subscriber.nil? ? nil : subscriber.reading_route_id
    end
    string :sort_no do
      bill_no
    end
    integer :sort_id do
      sort_id
    end
  end
end


# Métodos:
# Suma de los subtotales de las facturas (Sum invoices subtotal)
# Suma de los importes de bonificaciones de las facturas
# Suma de las bases imponibles de las facturas
# Suma de los impuestos de las facturas
# Suma de los totales de las facturas
