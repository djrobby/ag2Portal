class Bill < ActiveRecord::Base
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
                  :reading_1_id, :reading_2_id, :organization_id, :payment_method_id

  has_many :invoices, dependent: :destroy
  has_many :invoice_items, through: :invoices
  has_many :client_payments
  has_many :instalments
  has_one :pre_bill
  has_many :cancelled_invoices
  has_many :active_invoices
  has_many :active_supply_invoices
  has_one :water_supply_contract                                      # Contract bill for: New contracting or change of holder (to NEW subscriber)
  has_one :water_supply_contract, foreign_key: "unsubscribe_bill_id"  # Service bill for: Change of holder or unsubscribe (to OLD subscriber, meter withdrawal)
  has_one :water_supply_contract, foreign_key: "bailback_bill_id"     # Contract bill for: Change of holder or unsubscribe (return of deposit to OLD subscriber)

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
  scope :commercial, -> { joins(:invoices).where("invoices.invoice_type_id != ? AND invoices.invoice_type_id != ?", InvoiceType::WATER, InvoiceType::CONTRACT).by_no }
  scope :service, -> { joins(:invoices).where(invoices: {invoice_type_id: InvoiceType::WATER}).by_no }
  scope :contracting, -> { joins(:invoices).where(invoices: {invoice_type_id: InvoiceType::CONTRACT}).by_no }

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

  def bill_type
    invoices.first.invoice_type rescue nil
  end

  def to_label
    full_no
  end

  def reading
    reading_2
  end

  def full_no
    # Bill no (Project code & year & sequential number) => PPPPPPPPPPPP-YYYY-NNNNNNN
    if bill_no == "$err"
      "000000000000-0000-0000000"
    else
      bill_no.blank? ? "" : bill_no[0..11] + '-' + bill_no[12..15] + '-' + bill_no[16..22]
    end
  end

  def total
    invoices.reject(&:marked_for_destruction?).sum(&:totals)
  end

  def debt
    invoices.reject(&:marked_for_destruction?).sum(&:debt)
    # debt = 0
    # invoices.each do |i|
    #   if !i.debt.blank?
    #     debt += i.debt
    #   end
    # end
    # debt
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

  searchable do
    text :bill_no #, :to_label, :fiscal_id, :phone, :full_name
    text :client_code_name_fiscal do
      client.full_name_or_company_code_fiscal unless client.blank?
    end
    text :subscriber_code_name_address_fiscal do
      subscriber.code_full_name_or_company_address_fiscal unless subscriber.blank?
    end
    text :entity_name_fiscal do
      client.entity.full_name_or_company_fiscal unless (client.blank? || client.entity.blank?)
    end
    string :bill_no, :multiple => true   # Multiple search values accepted in one search (inverse_no_search)
    integer :project_id, :multiple => true
    integer :invoice_status_id
    integer :client_id
    integer :subscriber_id
    integer :entity_id do
      client.entity_id unless (client.blank? || client.entity_id.blank?)
    end
    boolean :bank_account do
      client.active_bank_accounts? unless client.blank?
    end
    integer :billing_period do
      reading_2.nil? ? nil : reading_2.billing_period_id
    end
    integer :reading_route_id do
      subscriber.nil? ? nil : subscriber.reading_route_id
    end
    string :sort_no do
      bill_no
    end
    date :created_at
    integer :organization_id
    integer :payment_method_id
  end
end


# Métodos:
# Suma de los subtotales de las facturas (Sum invoices subtotal)
# Suma de los importes de bonificaciones de las facturas
# Suma de las bases imponibles de las facturas
# Suma de los impuestos de las facturas
# Suma de los totales de las facturas
