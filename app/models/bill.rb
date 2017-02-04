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
  belongs_to :reading_1, :class_name => 'Reading' #periodo anterior
  belongs_to :reading_2, :class_name => 'Reading' #año anterior

  attr_accessible :bill_date, :bill_no, :first_name, :last_name, :company, :fiscal_id,
                  :project_id, :invoice_status_id, :subscriber_id, :client_id,
                  :street_type_id, :street_name, :street_number, :building, :floor, :floor_office,
                  :zipcode_id, :town_id, :province_id, :region_id, :country_id, :created_by, :updated_by,
                  :reading_1_id, :reading_2_id, :organization_id, :payment_method_id

  has_many :invoices, dependent: :destroy
  has_many :client_payments
  has_many :instalments
  has_one :water_supply_contract
  has_one :pre_bill
  has_many :cancelled_invoices
  has_many :active_invoices
  has_many :active_supply_invoices

  validates :bill_no,         :presence => true,
                              :length => { :is => 23 },
                              :format => { with: /\A[a-zA-Z\d]+\Z/, message: :code_invalid },
                              :uniqueness => { :scope => :organization_id }
  validates :bill_date,       :presence => true
  validates :organization,    :presence => true
  validates :project,         :presence => true
  validates :client,          :presence => true

  def total_by_concept(billable_concept)
    invoices.map(&:invoice_items).flatten.select{|item| item.tariff.billable_item.billable_concept_id == billable_concept.to_i and item.subcode != 'CF'}.sum(&:amount)
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

  def to_label
    full_no
  end

  def reading
    reading_2
  end

  def bill_type
    invoices.first.invoice_type rescue nil
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
    total = 0
    invoices.each do |i|
      if !i.total.blank?
        total += i.total
      end
    end
    total
  end

  def debt
    debt = 0
    invoices.each do |i|
      if !i.debt.blank?
        debt += i.debt
      end
    end
    debt
  end

  def subtotal
    subtotal = 0
    invoices.each do |i|
      if !i.subtotal.blank?
        subtotal += i.subtotal
      end
    end
    subtotal
  end

  def bonus
    bonus = 0
    invoices.each do |i|
      if !i.bonus.blank?
        bonus += i.bonus
      end
    end
    bonus
  end

  def taxes
    taxes = 0
    invoices.each do |i|
      if !i.taxes.blank?
        taxes += i.taxes
      end
    end
    taxes
  end

  def taxable
    taxable = 0
    invoices.each do |i|
      if !i.taxable.blank?
        taxable += i.taxable
      end
    end
    taxable
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
