# encoding: utf-8

# Replaceable latin symbols UTF-8 = ASCII-8BIT (ISO-8859-1)
# Á = \xC1  á = \xE1
# É = \xC9  é = \xE9
# Í = \xCD  í = \xED
# Ó = \xD3  ó = \xF3
# Ú = \xDA  ú = \xFA
# Ü = \xDC  ü = \xFC
# Ñ = \xD1  ñ = \xF1
# Ç = \xC7  ç = \xE7
# ¿ = \xBF  ¡ = \xA1
# ª = \xAA  º = \xBA

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
  belongs_to :company
  attr_accessible :discount, :discount_pct, :invoice_date, :invoice_no, :remarks,
                  :supplier_id, :payment_method_id, :project_id, :work_order_id, :charge_account_id,
                  :posted_at, :organization_id, :receipt_note_id, :purchase_order_id, :attachment,
                  :internal_no, :withholding, :totals, :payday_limit, :company_id
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
  validates :company,        :presence => true
  validates :internal_no,    :presence => true,
                             :length => { :minimum => 8, :maximum => 13 },
                             :uniqueness => { :scope => :company_id }


  # Scopes
  scope :by_no, -> { order(:invoice_no) }
  scope :by_date, -> { order(:invoice_date) }
  scope :by_created_at, -> { order(:created_at) }
  # scope :by_projects_and_creation_date, -> p, f, t { where("project_id IN (?) AND created_at BETWEEN ? AND ?", p, f, t).by_created_at }
  scope :by_projects_and_creation_date, -> p, f, t {
    where("project_id IN (?) AND ((posted_at IS NULL AND created_at BETWEEN ? AND ?) OR (NOT posted_at IS NULL AND posted_at BETWEEN ? AND ?))", p, f, t, f, t)
    .by_created_at
  }

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

  def full_internal_no
    # Internal no (Company id & year & sequential number) => CCC-YYYY-NNNNNN
    internal_no.blank? ? "" : internal_no[0..2] + '-' + internal_no[3..6] + '-' + internal_no[7..12]
  end

  def serial_from_internal_no
    posting_date = posted_at.blank? ? created_at : posted_at
    internal_no.blank? ? posting_date.year.to_s[2..3] : internal_no[5..6]
  end

  def number_from_internal_no
    internal_no.blank? ? id.to_s : internal_no[7..12]
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

  def calc_payday_limit
    days_to_expiration = self.payment_method.expiration_days.blank? ? 0 : self.payment_method.expiration_days
    self.created_at.blank? ? Time.new + days_to_expiration.days : self.created_at + days_to_expiration.days
  end

  def approved_to_pay
    supplier_invoice_approvals.sum(:approved_amount)
  end

  def amount_not_yet_approved
    total - approved_to_pay
  end

  def items_order_by_charge_account
    supplier_invoice_items.order(:charge_account_id, :id)
  end

  def items_group_by_charge_account(company_id=nil)
    if company_id.nil?
      supplier_invoice_items
        .joins("INNER JOIN (charge_accounts LEFT JOIN ledger_accounts ON charge_accounts.ledger_account_id=ledger_accounts.id) ON supplier_invoice_items.charge_account_id=charge_accounts.id")
        .group("ledger_accounts.code")
        .select('charge_account_id, ledger_accounts.code, sum(supplier_invoice_items.quantity*(supplier_invoice_items.price-supplier_invoice_items.discount)) AS item_amount')
        .order("item_amount")
    else
      supplier_invoice_items
        .joins("INNER JOIN (charge_accounts LEFT JOIN (charge_account_ledger_accounts INNER JOIN ledger_accounts ON charge_account_ledger_accounts.ledger_account_id=ledger_accounts.id) ON charge_accounts.id=charge_account_ledger_accounts.charge_account_id) ON supplier_invoice_items.charge_account_id=charge_accounts.id")
        .where("charge_account_ledger_accounts.company_id = ?", company_id)
        .group("ledger_accounts.code")
        .select('supplier_invoice_items.charge_account_id, ledger_accounts.code, sum(supplier_invoice_items.quantity*(supplier_invoice_items.price-supplier_invoice_items.discount)) AS item_amount')
        .order("item_amount")
    end
  end

  def items_group_by_tax_type(company_id=nil)
    if company_id.nil?
      supplier_invoice_items
        .joins("INNER JOIN (tax_types LEFT JOIN ledger_accounts ON tax_types.output_ledger_account_id=ledger_accounts.id) ON supplier_invoice_items.tax_type_id=tax_types.id")
        .group(:tax_type_id)
        .select('tax_type_id, tax_types.tax AS tax_rate, ledger_accounts.code, sum(supplier_invoice_items.quantity*(supplier_invoice_items.price-supplier_invoice_items.discount)) AS item_amount, (sum(supplier_invoice_items.quantity*(supplier_invoice_items.price-supplier_invoice_items.discount)))*(tax_types.tax/100) AS item_tax')
    else
      supplier_invoice_items
        .joins("INNER JOIN (tax_types LEFT JOIN (tax_type_ledger_accounts INNER JOIN ledger_accounts ON tax_type_ledger_accounts.output_ledger_account_id=ledger_accounts.id) ON tax_types.id=tax_type_ledger_accounts.tax_type_id) ON supplier_invoice_items.tax_type_id=tax_types.id")
        .where("tax_type_ledger_accounts.company_id = ?", company_id)
        .group(:tax_type_id)
        .select('supplier_invoice_items.tax_type_id, tax_types.tax AS tax_rate, ledger_accounts.code, sum(supplier_invoice_items.quantity*(supplier_invoice_items.price-supplier_invoice_items.discount)) AS item_amount, (sum(supplier_invoice_items.quantity*(supplier_invoice_items.price-supplier_invoice_items.discount)))*(tax_types.tax/100) AS item_tax')
    end
  end

  # Obtaining ledger account
  def ledger_account_id_by_charge_account_id(charge_account_id=nil, company_id=nil)
    if charge_account_id.nil?
      charge_account.ledger_account_id
    else
      charge_account_ledger_accounts.where(charge_account_id: charge_account_id, company_id: company_id).first.ledger_account_id rescue charge_account.ledger_account_id
    end
  end
  def ledger_account_code(charge_account_id=nil, company_id=nil)
    LedgerAccount.find(ledger_account_id_by_charge_account_id(charge_account_id, company_id)).code rescue nil
  end

  # Obtaining ledger account app company code
  def ledger_account_company_code(company_id=nil)
    _ret = '9999'
    if !company_id.nil?
      _ret = Company.find(company_id).ledger_account_app_code rescue '9999'
    end
    _ret.blank? ? '9999' : _ret
  end

  # Formatted attributes
  def format_date(_date)
    formatted_date(_date)
  end
  def format_number(_number, _d)
    formatted_number(_number, _d)
  end
  def raw_number(_number, _d)
    formatted_number_without_delimiter(_number, _d)
  end

  #
  # Class (self) user defined methods
  #
  def self.effects_portfolio_to_csv(array, company_id=nil)
    column_names = [I18n.t('activerecord.csv_sage200.effects_portfolio.c001'),
                    I18n.t('activerecord.csv_sage200.effects_portfolio.c002'),
                    I18n.t('activerecord.csv_sage200.effects_portfolio.c003'),
                    I18n.t('activerecord.csv_sage200.effects_portfolio.c004'),
                    I18n.t('activerecord.csv_sage200.effects_portfolio.c005'),
                    I18n.t('activerecord.csv_sage200.effects_portfolio.c006'),
                    I18n.t('activerecord.csv_sage200.effects_portfolio.c007'),
                    I18n.t('activerecord.csv_sage200.effects_portfolio.c008'),
                    I18n.t('activerecord.csv_sage200.effects_portfolio.c009'),
                    I18n.t('activerecord.csv_sage200.effects_portfolio.c010'),
                    I18n.t('activerecord.csv_sage200.effects_portfolio.c011'),
                    I18n.t('activerecord.csv_sage200.effects_portfolio.c012'),
                    I18n.t('activerecord.csv_sage200.effects_portfolio.c013'),
                    I18n.t('activerecord.csv_sage200.effects_portfolio.c014'),
                    I18n.t('activerecord.csv_sage200.effects_portfolio.c015'),
                    I18n.t('activerecord.csv_sage200.effects_portfolio.c016'),
                    I18n.t('activerecord.csv_sage200.effects_portfolio.c017'),
                    I18n.t('activerecord.csv_sage200.effects_portfolio.c018'),
                    I18n.t('activerecord.csv_sage200.effects_portfolio.c019'),
                    I18n.t('activerecord.csv_sage200.effects_portfolio.c020'),
                    I18n.t('activerecord.csv_sage200.effects_portfolio.c021'),
                    I18n.t('activerecord.csv_sage200.effects_portfolio.c022'),
                    I18n.t('activerecord.csv_sage200.effects_portfolio.c023'),
                    I18n.t('activerecord.csv_sage200.effects_portfolio.c024')]
    col_sep = I18n.locale == :es ? ";" : ","
    CSV.generate(headers: true, col_sep: col_sep, row_sep: "\r\n") do |csv|
      csv << column_names
      lac = nil
      entry = 0
      array.each do |i|
        entry = 1
        # Load tax_type lines
        ttl = i.items_group_by_tax_type(company_id)
        if ttl.to_a.count <= 0
          # No ttl records found
          break
        end
        # Totals for effect line
        taxable_sum = 0
        tax_sum = 0
        totals = 0
        ttl.each do |g|
          if !g.code.blank?
            taxable_sum += g.item_amount.round(2)
            tax_sum += g.item_tax.round(2)
          end
        end
        totals = i.raw_number(taxable_sum + tax_sum, 2)
        # Effect line
        lac = i.supplier.ledger_account_code(company_id)
        days_to_expiration = i.payment_method.expiration_days.blank? ? 0 : i.payment_method.expiration_days
        expiration = i.payday_limit.blank? ? i.invoice_date + days_to_expiration.days : i.payday_limit
        posting_date = i.posted_at.blank? ? i.created_at : i.posted_at
        if !lac.nil?
          csv << [i.ledger_account_company_code(company_id),  # 001
                  nil,  # 002
                  nil,  # 003
                  'P',                                        # 004
                  entry.to_s,                                 # 005
                  posting_date.year.to_s,                     # 006
                  i.serial_from_internal_no,                  # 007
                  i.number_from_internal_no,                  # 008
                  i.invoice_no,                               # 009
                  i.supplier.supplier_code,                   # 010
                  lac,                                        # 011
                  nil,  # 012
                  i.format_date(posting_date),                # 013
                  i.format_date(i.invoice_date),              # 014
                  i.format_date(expiration),                  # 015
                  totals,                                     # 016
                  '-1',                                       # 017
                  i.invoice_no,                               # 018
                  '0',                                        # 019
                  i.supplier.active_bank_account_bank_code,       # 020
                  i.supplier.active_bank_account_office_code,     # 021
                  i.supplier.active_bank_account_ccc_dc,          # 022
                  i.supplier.active_bank_account_ccc_account_no,  # 023
                  i.supplier.active_bank_account_iban_no]         # 024
        end # !lac.nil?
      end # array.each
    end # CSV.generate
  end

  def self.to_csv(array, company_id=nil)
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
    col_sep = I18n.locale == :es ? ";" : ","
    CSV.generate(headers: true, col_sep: col_sep, row_sep: "\r\n") do |csv|
      csv << column_names
      lac = nil
      entry = 0
      array.each do |i|
        entry += 1
        # Load charge_account & tax_type lines
        cal = i.items_group_by_charge_account(company_id)
        ttl = i.items_group_by_tax_type(company_id)
        if cal.to_a.count <= 0 || ttl.to_a.count <= 0
          # No cal or ttl records found
          break
        end
        # Gross & Net amounts for supplier line
        _g = 1
        taxable1 = nil
        tax1 = nil
        taxcode1 = nil
        taxrate1 = nil
        taxable2 = nil
        tax2 = nil
        taxcode2 = nil
        taxrate2 = nil
        taxable3 = nil
        tax3 = nil
        taxcode3 = nil
        taxrate3 = nil
        taxable_sum = 0
        tax_sum = 0
        totals = 0
        ttl.each do |g|
          if !g.code.blank?
            case _g
            when 1
              taxable1 = i.raw_number(g.item_amount, 2)
              tax1 = i.raw_number(g.item_tax, 2)
              taxcode1 = g.tax_rate.to_i.to_s
              taxrate1 = i.raw_number(g.tax_rate, 2)
            when 2
              taxable2 = i.raw_number(g.item_amount, 2)
              tax2 = i.raw_number(g.item_tax, 2)
              taxcode2 = g.tax_rate.to_i.to_s
              taxrate2 = i.raw_number(g.tax_rate, 2)
            when 3
              taxable3 = i.raw_number(g.item_amount, 2)
              tax3 = i.raw_number(g.item_tax, 2)
              taxcode3 = g.tax_rate.to_i.to_s
              taxrate3 = i.raw_number(g.tax_rate, 2)
            end
            taxable_sum += g.item_amount.round(2)
            tax_sum += g.item_tax.round(2)
          end
          _g += 1
        end
        totals = i.raw_number(taxable_sum + tax_sum, 2)
        # Withholding
        withholding_invoiced = 0
        withholding_tax_pct = 0
        withholding_code = nil
        withholding_taxable = nil
        withholding_tax = nil
        withholding_amount = nil
        withholding_type = nil
        withholding_ledger_account = nil
        if !i.withholding.blank? && i.withholding < 0
          totals = i.raw_number(taxable_sum + tax_sum + i.withholding, 2)
          withholding_invoiced = i.withholding * (-1)
          withholding_tax_pct = ((withholding_invoiced / taxable_sum) * 100).round(1)
          withholding_taxable = i.raw_number(taxable_sum, 2)
          withholding_tax = i.raw_number(withholding_tax_pct, 1)
          withholding_amount = i.raw_number(withholding_invoiced, 2)
          withholding_type = WithholdingType.find_by_tax(withholding_tax_pct)
          if withholding_type.nil?
            withholding_code = withholding_tax_pct.round(0).to_s
            withholding_ledger_account = '475100922'
          else
            withholding_code = withholding_type.ledger_account_app_code_formatted rescue withholding_tax_pct.round(0).to_s
            withholding_ledger_account = withholding_type.ledger_account_code rescue '475100922'
          end
        end
        # Posting date
        posting_date = i.posted_at.blank? ? i.created_at : i.posted_at
        # Group 4 (40) lines: supplier
        lac = i.supplier.ledger_account_code(company_id)
        if !lac.nil? && !taxable1.nil?
          csv << [i.ledger_account_company_code(company_id),  # 001
                  posting_date.year.to_s,                   # 002
                  entry.to_s,                               # 003
                  'H',                                      # 004
                  lac,                                      # 005
                  nil,  # 006
                  i.format_date(posting_date),              # 007
                  nil,  # 008
                  i.invoice_no,                             # 009
                  totals,                                   # 010
                  nil,  # 011
                  nil,  # 012
                  nil,  # 013
                  nil,  # 014
                  nil,  # 015
                  nil,  # 016
                  nil,  # 017
                  posting_date.month.to_s,                  # 018
                  '2',                                      # 019
                  '0',                                      # 020
                  '0',                                      # 021
                  taxable1,                                 # 022
                  taxcode1,                                 # 023
                  taxrate1,                                 # 024
                  tax1,                                     # 025
                  nil,  # 026
                  nil,  # 027
                  nil,  # 028
                  taxable2,                                 # 029
                  taxcode2,                                 # 030
                  taxrate2,                                 # 031
                  tax2,                                     # 032
                  nil,  # 033
                  nil,  # 034
                  nil,  # 035
                  taxable3,                                 # 036
                  taxcode3,                                 # 037
                  taxrate3,                                 # 038
                  tax3,                                     # 039
                  nil,  # 040
                  nil,  # 041
                  nil,  # 042
                  i.serial_from_internal_no,                # 043
                  i.number_from_internal_no,                # 044
                  i.invoice_no,                             # 045
                  i.format_date(i.invoice_date),            # 046
                  totals,                                   # 047
                  'R',                                      # 048
                  i.supplier.fiscal_id,                     # 049
                  i.supplier.name35,                        # 050
                  withholding_code,                         # 051
                  withholding_taxable,                      # 052
                  withholding_tax,                          # 053
                  withholding_amount,                       # 054
                  i.supplier.province.territory_code,       # 055
                  i.supplier.country.code,                  # 056
                  Time.new.year.to_s,                       # 057
                  nil,  # 058
                  'P',                                      # 059
                  '0']                                      # 060
        end # !lac.nil? && !taxable1.nil?
        # Group 6 lines: charge_accounts
        taxable_sum_dif = taxable_sum
        cal.each do |g|
          if !g.code.blank?
            g_item_amount = g.item_amount.round(2)
            amount_to_inform = taxable_sum_dif < g_item_amount ? i.raw_number(taxable_sum_dif, 2) : i.raw_number(g_item_amount, 2)
            taxable_sum_dif -= g_item_amount
            csv << [i.ledger_account_company_code(company_id),  # 001
                    posting_date.year.to_s,                   # 002
                    entry.to_s,                               # 003
                    'D',                                      # 004
                    g.code,                                   # 005
                    nil,  # 006
                    i.format_date(posting_date),              # 007
                    nil,  # 008
                    i.invoice_no,                             # 009
                    amount_to_inform,                         # 010
                    nil,  # 011
                    nil,  # 012
                    nil,  # 013
                    nil,  # 014
                    nil,  # 015
                    nil,  # 016
                    nil,  # 017
                    posting_date.month.to_s,                  # 018
                    '0',                                      # 019
                    '0',                                      # 020
                    '0',                                      # 021
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
          end # !g.code.blank?
        end # i.items_group_by_charge_account.each
        # Group 4 (47) lines: taxes
        ttl.each do |g|
          if !g.code.blank?
            csv << [i.ledger_account_company_code(company_id),  # 001
                    posting_date.year.to_s,                   # 002
                    entry.to_s,                               # 003
                    'D',                                      # 004
                    g.code,                                   # 005
                    nil,  # 006
                    i.format_date(posting_date),              # 007
                    nil,  # 008
                    i.invoice_no,                             # 009
                    i.raw_number(g.item_tax, 2),              # 010
                    nil,  # 011
                    nil,  # 012
                    nil,  # 013
                    nil,  # 014
                    nil,  # 015
                    nil,  # 016
                    nil,  # 017
                    posting_date.month.to_s,                  # 018
                    '0',                                      # 019
                    '0',                                      # 020
                    '0',                                      # 021
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
          end # !g.code.blank?
        end # i.items_group_by_tax_type.each
        # Group 4 (47) line: withholding
        if !withholding_ledger_account.nil? && !withholding_amount.nil?
          csv << [i.ledger_account_company_code(company_id),  # 001
                  posting_date.year.to_s,                   # 002
                  entry.to_s,                               # 003
                  'H',                                      # 004
                  withholding_ledger_account,               # 005
                  nil,  # 006
                  i.format_date(posting_date),              # 007
                  nil,  # 008
                  i.invoice_no,                             # 009
                  withholding_amount,                       # 010
                  nil,  # 011
                  nil,  # 012
                  nil,  # 013
                  nil,  # 014
                  nil,  # 015
                  nil,  # 016
                  nil,  # 017
                  posting_date.month.to_s,                  # 018
                  '0',                                      # 019
                  '0',                                      # 020
                  '0',                                      # 021
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
        end # !withholding_ledger_account.nil? && !withholding_amount.nil?
      end # array.each
    end # CSV.generate
  end

  def self.to_report_invoices_csv(array)
    attributes = [I18n.t('activerecord.attributes.supplier_invoice.invoice_no'),
                  I18n.t('activerecord.attributes.supplier_invoice.invoice_date'),
                  I18n.t('activerecord.attributes.supplier_invoice.payday_limit'),
                  I18n.t('activerecord.attributes.supplier_invoice.receipt_note'),
                  I18n.t('activerecord.attributes.supplier_invoice.supplier'),
                  I18n.t('activerecord.attributes.supplier_invoice.payment_method'),
                  I18n.t('activerecord.attributes.supplier_invoice.project'),
                  I18n.t('activerecord.attributes.supplier_invoice.work_order'),
                  I18n.t('activerecord.attributes.supplier_invoice.charge_account'),
                  I18n.t('activerecord.attributes.supplier_invoice.purchase_order'),
                  I18n.t('activerecord.attributes.supplier_invoice.internal_no'),
                  I18n.t('activerecord.attributes.supplier_invoice.debt'),
                  I18n.t('activerecord.attributes.supplier_invoice.quantity'),
                  I18n.t('activerecord.attributes.supplier_invoice.subtotal'),
                  I18n.t('activerecord.attributes.supplier_invoice.withholding'),
                  I18n.t('activerecord.attributes.supplier_invoice.discount_pct'),
                  I18n.t('activerecord.attributes.supplier_invoice.bonus'),
                  I18n.t('activerecord.attributes.supplier_invoice.taxable'),
                  I18n.t('activerecord.attributes.supplier_invoice.taxes'),
                  I18n.t('activerecord.attributes.supplier_invoice.total')]
    col_sep = I18n.locale == :es ? ";" : ","
    CSV.generate(headers: true, col_sep: col_sep, row_sep: "\r\n") do |csv|
      csv << attributes
      array.each do |supplier_invoices_report|
        csv << [  supplier_invoices_report.invoice_no,
                  supplier_invoices_report.invoice_date,
                  supplier_invoices_report.payday_limit,
                  supplier_invoices_report.try(:receipt_note).try(:receipt_no),
                  supplier_invoices_report.try(:supplier).try(:full_name),
                  supplier_invoices_report.try(:payment_method).try(:description) ,
                  supplier_invoices_report.try(:project).try(:full_name),
                  supplier_invoices_report.try(:work_order).try(:full_name),
                  supplier_invoices_report.try(:charge_account).try(:full_name),
                  supplier_invoices_report.try(:purchase_order).try(:full_no),
                  supplier_invoices_report.internal_no,
                  supplier_invoices_report.debt,
                  supplier_invoices_report.quantity,
                  supplier_invoices_report.subtotal,
                  supplier_invoices_report.withholding,
                  supplier_invoices_report.discount_pct,
                  supplier_invoices_report.bonus,
                  supplier_invoices_report.taxable,
                  supplier_invoices_report.taxes,
                  supplier_invoices_report.total]
      end
    end
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
    # Payday limit
    self.payday_limit = calc_payday_limit if self.payday_limit.blank?
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
