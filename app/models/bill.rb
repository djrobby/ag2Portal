# encoding: utf-8

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
  has_many :invoice_debts
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
  scope :service_by_project_period_subscriber, -> p, b, s {
    joins(:invoices)
    .where('invoices.invoice_type_id = ? AND bills.project_id = ? AND invoices.billing_period_id = ? AND bills.subscriber_id = ?', InvoiceType::WATER, p, b, s)
    .group('bills.id').by_no
  }
  scope :service_by_project_period_no, -> p, b, f, t {
    joins(:invoices)
    .where('invoices.invoice_type_id = ? AND bills.project_id = ? AND invoices.billing_period_id = ? AND bills.bill_no BETWEEN ? AND ?', InvoiceType::WATER, p, b, f, t)
    .by_no
  }
  scope :service_by_project_period_invoice_no, -> p, b, f, t {
    joins(:invoices)
    .where('invoices.invoice_type_id = ? AND bills.project_id = ? AND invoices.billing_period_id = ? AND invoices.invoice_no BETWEEN ? AND ?', InvoiceType::WATER, p, b, f, t)
    .by_no
  }
  scope :g_where, -> w {
    joins(:invoices)
    .where(w)
    .by_no
  }
  scope :by_subscriber_full, -> s, t {
    # joins(:invoice_status, invoices: [:invoice_type, :invoice_operation, [invoice_items: :tax_type]])
    joins("LEFT JOIN invoices ON bills.id=invoices.bill_id")
    .joins("LEFT JOIN billing_periods ON invoices.billing_period_id=billing_periods.id")
    .joins("LEFT JOIN readings ON bills.reading_2_id=readings.id")
    .joins("LEFT JOIN client_payments ON bills.id=client_payments.bill_id")
    .where("bills.subscriber_id = #{s} AND bills.invoice_status_id IN (#{t}) AND invoices.invoice_type_id IN (#{InvoiceType.billable_by_subscriber})")
    .select("bills.id bill_id_, bills.bill_no bill_no_, bills.old_no old_no_, bills.invoice_status_id bill_status_id_,
             MIN(invoices.invoice_type_id) bill_type_id_, MIN(invoices.invoice_operation_id) bill_operation_id_,
             bills.client_id client_id_, bills.subscriber_id subscriber_id_,
             bills.bill_date bill_date_, MIN(invoices.payday_limit) bill_payday_limit_, SUM(invoices.totals) bill_total_,
             (SUM(invoices.receivables) - CASE WHEN ISNULL(client_payments.amount) THEN 0 ELSE SUM(client_payments.amount) END) bill_debt_,
             CASE WHEN ISNULL(client_payments.amount) THEN 0 ELSE SUM(client_payments.amount) END bill_charged_,
             CASE WHEN ISNULL(bills.old_no) THEN CONCAT(SUBSTR(bills.bill_no,1,12),'-',SUBSTR(bills.bill_no,13,4),'-',SUBSTR(bills.bill_no,17,7)) ELSE bills.old_no END bill_right_no_,
             CASE WHEN ISNULL(invoices.old_no) THEN CONCAT(SUBSTR(invoices.invoice_no,1,5),'-',SUBSTR(invoices.invoice_no,6,4),'-',SUBSTR(invoices.invoice_no,10,7)) ELSE invoices.old_no END invoice_based_old_no_real_no_,
             CASE WHEN ISNULL(invoices.billing_period_id) THEN '' ELSE billing_periods.period END billing_period_,
             CASE WHEN (MIN(invoices.invoice_operation_id)=1 OR MIN(invoices.invoice_operation_id)=3) AND MIN(invoices.invoice_type_id)=#{InvoiceType::WATER} THEN readings.bill_id = bills.id ELSE NULL END nullable_")
     .group('bills.id').order('invoices.billing_period_id DESC,bills.bill_date DESC,bills.id DESC')
  }
  scope :by_subscriber_total, -> s, t {
    joins("LEFT JOIN invoices ON bills.id=invoices.bill_id")
    .where("bills.subscriber_id = #{s} AND bills.invoice_status_id IN (#{t}) AND invoices.invoice_type_id IN (#{InvoiceType.billable_by_subscriber})")
    .select("SUM(invoices.totals) bills_total")
  }

  #
  # Methods
  #
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
  def invoice_based_old_no_real_no
    ibon = invoice_based_old_no
    ibon.blank? ? real_no : ibon
  end
  def old_no_based_no
    old_no.blank? ? full_no : old_no
  end
  def old_no_based_real_no
    old_no.blank? ? real_no : old_no
  end
  def raw_invoice_based_no
    _i = invoices.first
    if _i.nil?
      ""
    else
      _old = _i.old_no
      _cur = _i.invoice_no
      _old.blank? ? _cur : _old
    end
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

  def bill_type_code
    invoices.first.invoice_type.code rescue ''
  end

  def company_
    project.company unless (project.blank? || project.company.blank?)
  end

  def office_
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
    company_numeric_fiscal_id + company_suffix
  end

  def ident
    if company_suffix < '500'
      subscriber.subscriber_code[5..10]
    else
      payday_limit.strftime("%d%m%y") rescue subscriber.subscriber_code[5..10]
    end
  end
  def ident_to_use_as_reference
    ident.to_d
  end

  def total_to_use_as_reference
    total.round(2) * 100
  end

  def reference
    no_to_use_as_reference + cc_reference
  end

  def cc_reference
    _s = (company_fiscal_id_to_use_as_reference +
          company_suffix_to_use_as_reference +
          no_to_use_as_reference.to_d +
          ident_to_use_as_reference +
          total_to_use_as_reference) / 97
    _s = (((_s - _s.to_i) * 100).to_i).to_s.rjust(2, '0')
  end

  def company_numeric_fiscal_id
    project.company.numeric_fiscal_id
  end
  def company_fiscal_id_to_use_as_reference
    company_numeric_fiscal_id.to_d
  end

  def company_suffix
    project.company.first_active_bank_suffix
  end
  def company_suffix_to_use_as_reference
    company_suffix.to_d
  end

  # 11 characters formatted invoice number, to use as reference
  def no_to_use_as_reference
    self.id.to_s.rjust(11, '0')
  end
  def old_fashioned_no_to_use_as_reference
    _i = invoices.first
    _old = _i.old_no
    _cur = _i.invoice_no
    if _old.blank?
      # Returns current invoice no formatted for reference
      cur_no_to_use_as_reference(_cur)
    else
      # Returns old invoice no formatted for reference
      old_no_to_use_as_reference(_old, _cur)
    end
  end
  def cur_no_to_use_as_reference(_cur)
    # Returns 11 digits: OO + YY + NNNNNNN from OFFICE (2) & YEAR (2) & NO (7)
    _cur[3..4] + _cur[7..8] + _cur[9..15] rescue ''
  end
  def old_no_to_use_as_reference(_old, _cur)
    # Returns 11 digits: SS + 0 + NNNNNNNN from SERIAL (2) & NFACT (8)
    _a = _old.split('/')
    if _a[0].first == 'A'
      _a[0][1..2].rjust(2, '0') + '0' + a[1][0..-1].rjust(8, '0') rescue cur_no_to_use_as_reference(_cur)
    else
      _a[0][0..1].rjust(2, '0') + '0' + a[1][0..-1].rjust(8, '0') rescue cur_no_to_use_as_reference(_cur)
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

  def address_1
    _ret = ""
    if !street_type.blank?
      _ret += street_type.street_type_code.titleize + ". "
    end
    if !street_name.blank?
      _ret += street_name + " "
    end
    if !street_number.blank?
      _ret += street_number
    end
    if !building.blank?
      _ret += ", " + building.titleize
    end
    if !floor.blank?
      _ret += ", " + floor_human
    end
    if !floor_office.blank?
      _ret += " " + floor_office
    end
    _ret
  end

  def address_2
    _ret = ""
    if !zipcode.blank?
      _ret += zipcode.zipcode + " "
    end
    if !town.blank?
      _ret += town.name + ", "
    end
    if !province.blank?
      _ret += province.name + " "
      if !province.region.country.blank?
        _ret += "(" + province.region.country.name + ")"
      end
    end
    _ret
  end

  def floor_human
    _ret = floor
    _floor_is_numeric = true if Float(floor) rescue false
    if _floor_is_numeric
      _ret = floor.strip + "\xBA".force_encoding('ISO-8859-1').encode('UTF-8')
    end
    _ret
  end

  def full_name
    full_name = ""
    if !company.blank?
      full_name = company
    else
      if !self.last_name.blank?
        full_name += self.last_name
      end
      if !self.first_name.blank?
        full_name += ", " + self.first_name
      end
      full_name[0,40]
    end
  end

  #
  # Calculated fields
  #
  def total
    (invoices.reject(&:marked_for_destruction?).sum(&:totals)).round(2)
  end

  def receivable
    (invoices.reject(&:marked_for_destruction?).sum(&:receivables)).round(2)
  end

  def collected
    (client_payments.sum(:amount)).round(2)
  end

  def debt
    invoices.reject(&:marked_for_destruction?).sum(&:debt)
  end

  def current_debt
    invoice_debts.sum(:debt) rescue 0
  end

  def current_collected
    invoice_debts.sum(:paid) rescue 0
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

  # Barcode generator
  def barcode_total
    total = self.total.round(2)
    ti = total.to_i
    tr = (total - ti).to_s
    trl = tr.length
    trr = (tr[2..trl]).ljust(2,"0")
    (ti.to_s + trr).rjust(10,"0")
  end
  def barcode
    ai = "90"
    cabecera = "507"
    issuer = self.issuer.to_s
    reference = self.reference.to_s
    ident = self.ident.to_s
    total = self.barcode_total
    pie = "0"
    ai + cabecera + issuer + reference + ident + total + pie
  end

  # Aux methods for CSV
  def raw_number(_number, _d)
    formatted_number_without_delimiter(_number, _d)
  end

  def sanitize(s)
    !s.blank? ? sanitize_string(s.strip, true, true, true, false) : ''
  end

  #
  # Class (self) user defined methods
  #
  def self.last_billed_date(company, office)
    joins(:project)
    .where('projects.company_id = ? AND projects.office_id = ?',company,office)
    .select('max(bill_date) max_bill_date_').first.max_bill_date_
  end

  def self.is_new_bill_date_valid?(new_bill_date, company, office)
    a = last_billed_date(company, office)
    a.nil? ? true : new_bill_date >= a
  end

  def self.without_invoices
    joins('LEFT JOIN invoices ON bills.id=invoices.bill_id').where('invoices.bill_id IS NULL')
  end

  # Search by old_no for SEPA counter
  # Parameter must be string & 11 digits length (SSNNNNNNNNN)
  def self.search_by_old_no_from_counter(o)
    old_no_to_search = o[0,2] + '/' + o[2..-1].to_i.to_s
    find_by_old_no(old_no_to_search)
  end

  # Search by old_no for SEPA return
  # Parameter must be string & 10 digits length (NNNNNNSS00)
  def self.search_by_old_no_from_return(o)
    old_no_to_search = o[6,2] + '/' + o[0,6].to_i.to_s
    find_by_old_no(old_no_to_search)
  end

  def self.to_csv(array,code=nil)
    attributes = ["Id " + array[0].sanitize(I18n.t("activerecord.models.bill.one")),
                  array[0].sanitize(I18n.t("activerecord.attributes.invoice.invoice_no")),
                  array[0].sanitize(I18n.t("activerecord.attributes.bill.bill_date")),
                  array[0].sanitize(I18n.t("ag2_gest.bills.index.payday_limit")),
                  array[0].sanitize(I18n.t("activerecord.attributes.report.billing_period")),
                  array[0].sanitize(I18n.t("activerecord.attributes.subscriber.subscriber_code2")),
                  array[0].sanitize(I18n.t("activerecord.attributes.bill.subscriber")),
                  array[0].sanitize(I18n.t("activerecord.attributes.subscriber.meter")),
                  array[0].sanitize(I18n.t("activerecord.attributes.invoice.invoice_type")),
                  array[0].sanitize(I18n.t("activerecord.attributes.invoice.invoice_status")),
                  array[0].sanitize(I18n.t("activerecord.attributes.invoice.invoice_operation")),
                  array[0].sanitize(I18n.t("activerecord.attributes.subscriber.equiv_dwelling")),
                  array[0].sanitize(I18n.t("activerecord.attributes.reading.lec_ant")),
                  array[0].sanitize(I18n.t("activerecord.attributes.reading.reading_date") + " "  + I18n.t("activerecord.attributes.reading.lec_ant")),
                  array[0].sanitize(I18n.t("activerecord.attributes.reading.lec_act")),
                  array[0].sanitize(I18n.t("activerecord.attributes.reading.reading_date") + " "  + I18n.t("activerecord.attributes.reading.lec_act")),
                  array[0].sanitize(I18n.t("activerecord.attributes.reading.reg")),
                  array[0].sanitize(I18n.t("activerecord.attributes.reading.est")),
                  array[0].sanitize(I18n.t("activerecord.attributes.reading.other")),
                  array[0].sanitize(I18n.t("activerecord.attributes.reading.fac")),
                  array[0].sanitize(I18n.t("activerecord.attributes.bill.subtotal")),
                  array[0].sanitize(I18n.t("activerecord.attributes.bill.taxes")),
                  array[0].sanitize(I18n.t("activerecord.attributes.bill.total"))]
                  code.each do |c|
                    attributes << c.code.to_s + " " +  "CF"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.quantity_c") + "CF"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.amount_c") + "CF"
                    attributes << c.code.to_s + " " + "CV"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.quantity_c") + "CV"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.amount_c") + "CV"
                    attributes << c.code.to_s + " " + "VP"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.quantity_c") + "VP"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.amount_c") + "VP"
                    attributes << c.code.to_s + " " + "FP"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.quantity_c") + "FP"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.amount_c") + "FP"
                    attributes << c.code.to_s + " " + "BL1"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.quantity_c") + "BL1"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.amount_c") + "BL1"
                    attributes << c.code.to_s + " " + "BL2"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.quantity_c") + "BL2"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.amount_c") + "BL2"
                    attributes << c.code.to_s + " " + "BL3"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.quantity_c") + "BL3"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.amount_c") + "BL3"
                    attributes << c.code.to_s + " " + "BL4"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.quantity_c") + "BL4"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.amount_c") + "BL4"
                    attributes << c.code.to_s + " " + "BL5"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.quantity_c") + "BL5"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.amount_c") + "BL5"
                    attributes << c.code.to_s + " " + "BL6"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.quantity_c") + "BL6"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.amount_c") + "BL6"
                    attributes << c.code.to_s + " " + "BL7"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.quantity_c") + "BL7"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.amount_c") + "BL7"
                    attributes << c.code.to_s + " " + "BL8"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.quantity_c") + "BL8"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.amount_c") + "BL8"
                  end

    col_sep = I18n.locale == :es ? ";" : ","
    CSV.generate(headers: true, col_sep: col_sep, row_sep: "\r\n") do |csv|
      csv << attributes
      array.each do |b|
        bill = Bill.find(b.b_id_) unless b.b_id_.blank?
        payday_limit = b.payday_limit_.strftime("%d/%m/%Y") unless b.payday_limit_.blank?
        csv_data = [  b.b_id_.blank? ? b.b_id_ : b.b_id_,
                  b.b_id_.blank? ? b.invoice_no_ : bill.try(:invoices).first.old_no_based_real_no,
                  b.invoice_date_.strftime("%d/%m/%Y"),
                  b.b_id_.blank? ? payday_limit : bill.try(:invoices).first.try(:payday_limit).strftime("%d/%m/%Y"),
                  b.billing_period_,
                  b.full_code_,
                  b.full_name_,
                  b.meter_code_,
                  b.invoice_type_,
                  b.invoice_status_,
                  b.invoice_operation_,
                  b.equiv_dwelling_.to_i,
                  b.reading_1_index_,
                  b.reading_1_date_,
                  b.reading_2_index_,
                  b.reading_2_date_,
                  b.consumption_real_,
                  b.consumption_estimated_,
                  b.consumption_other_,
                  b.consumption_,
                  b.raw_number(Invoice.find(b.p_id_).subtotal, 4),
                  b.raw_number(Invoice.find(b.p_id_).net_tax, 4),
                  b.raw_number(b.totals_, 4)]
        code.each do |c|
        data2 = [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil]
          InvoiceItem.where('invoice_id = ?',b.p_id_).each do |i|
            if c.code == i.code
              quantity_ = i.quantity.blank? ? nil : b.raw_number(i.quantity, 2)
              amount_ = i.amount.blank? ? nil : b.raw_number(i.amount, 4)
              if i.code == "CON"
                data2[0] = i.measure.description
                data2[1] = quantity_
                data2[2] = amount_
              else
                if i.subcode == "CF"
                  data2[0] = i.measure.description
                  data2[1] = quantity_
                  data2[2] = amount_
                end
                if i.subcode == "CV"
                  data2[3] = i.measure.description
                  data2[4] = quantity_
                  data2[5] = amount_
                end
                if i.subcode == "VP"
                  data2[6] = i.measure.description
                  data2[7] = quantity_
                  data2[8] = amount_
                end
                if i.subcode == "FP"
                  data2[9] = i.measure.description
                  data2[10] = quantity_
                  data2[11] = amount_
                end
                if i.subcode == "BL1"
                  data2[12] = i.measure.description
                  data2[13] = quantity_
                  data2[14] = amount_
                end
                if i.subcode == "BL2"
                  data2[15] = i.measure.description
                  data2[16] = quantity_
                  data2[17] = amount_
                end
                if i.subcode == "BL3"
                  data2[18] = i.measure.description
                  data2[19] = quantity_
                  data2[20] = amount_
                end
                if i.subcode == "BL4"
                  data2[21] = i.measure.description
                  data2[22] = quantity_
                  data2[23] = amount_
                end
                if i.subcode == "BL5"
                  data2[24] = i.measure.description
                  data2[25] = quantity_
                  data2[26] = amount_
                end
                if i.subcode == "BL6"
                  data2[27] = i.measure.description
                  data2[28] = quantity_
                  data2[29] = amount_
                end
                if i.subcode == "BL7"
                  data2[30] = i.measure.description
                  data2[31] = quantity_
                  data2[32] = amount_
                end
                if i.subcode == "BL8"
                  data2[33] = i.measure.description
                  data2[34] = quantity_
                  data2[35] = amount_
                end
              end
            end # if c.code == i.code
          end # PreInvoiceItem.where('pre_invoice_id = ?',b.p_id_).each do |i|
          csv_data += data2
        end # code.each do |c|
        csv << csv_data
      end #array.each do |b| #array.each do |b|
    end
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
    string :bill_no, :multiple => true        # Multiple search values accepted in one search (inverse_no_search)
    string :invoice_no, :multiple => true do  # Multiple search values accepted in one search (inverse_no_search)
      raw_invoice_based_no
    end
    integer :invoice_status_id
    integer :project_id, :multiple => true
    integer :client_id
    integer :subscriber_id
    integer :client_ids, :multiple => true do
      client_id
    end
    integer :subscriber_ids, :multiple => true do
      subscriber_id unless subscriber_id.blank?
    end
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
