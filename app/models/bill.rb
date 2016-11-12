class Bill < ActiveRecord::Base
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
                  :reading_1_id, :reading_2_id

  has_many :invoices
  has_many :client_payments
  has_many :instalments
  has_one :water_supply_contract
  has_one :pre_bill

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
    # Order no (Project code & year & sequential number) => PPPPPPPPPPPP-YYYY-NNNNNN
    if bill_no == "$err"
      "000000000000-000-00000"
    else
      bill_no.blank? ? "" : bill_no[0..11] + '-' + bill_no[12..15] + '-' + bill_no[16..21]
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
    string :bill_no, :multiple => true   # Multiple search values accepted in one search (inverse_no_search)
    integer :project_id, :multiple => true
    integer :invoice_status_id
    integer :client_id
    integer :subscriber_id
    integer :entity_id do
      client.entity_id
    end
    boolean :bank_account do
      client.active_bank_accounts?
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
  end

end


# Métodos:
# Suma de los subtotales de las facturas (Sum invoices subtotal)
# Suma de los importes de bonificaciones de las facturas
# Suma de las bases imponibles de las facturas
# Suma de los impuestos de las facturas
# Suma de los totales de las facturas
