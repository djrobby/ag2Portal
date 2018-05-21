class ClientPayment < ActiveRecord::Base
  include ModelsModule

  # CONSTANTS (payment_type model)
  CASH = 1          # CAJA
  BANK = 2          # BANCO
  FRACTIONATED = 3  # APLAZAMIENTO
  COUNTER = 4       # VENTANILLA BANCARIA
  OTHERS = 5        # OTROS

  belongs_to :bill
  belongs_to :invoice
  belongs_to :payment_method
  belongs_to :client
  belongs_to :client_bank_account
  belongs_to :subscriber
  belongs_to :instalment
  belongs_to :charge_account
  belongs_to :sepa_return_code
  attr_accessible :receipt_no, :payment_type, :payment_date, :confirmation_date, :amount, :surcharge,
                  :bill_id, :invoice_id, :client_id, :client_bank_account_id, :subscriber_id,
                  :instalment_id, :charge_account_id, :payment_method_id, :created_by, :updated_by,
                  :sepa_return_code_id

  has_many :cash_desk_closing_items

  has_paper_trail


  validates :bill,              :presence => true
  validates :invoice,           :presence => true
  validates :payment_method,    :presence => true
  validates :client,            :presence => true

  # Scopes
  scope :by_no, -> { order(:receipt_no) }
  scope :by_bill, -> { order(:bill_id) }
  scope :by_bill_invoice, -> { order(:bill_id, :invoice_id) }
  #
  scope :none, where("1 = 0")
  scope :in_cash, -> { where(payment_type: CASH) }
  scope :in_bank, -> { where(payment_type: BANK) }
  scope :in_deferrals, -> { where(payment_type: FRACTIONATED) }
  scope :in_counter, -> { where(payment_type: COUNTER) }
  scope :in_others, -> { where(payment_type: OTHERS) }
  # By bill for bank order
  scope :by_bill_for_bank_order, -> cp {
    select("min(id) id, min(receipt_no) receipt_no, min(payment_type) payment_type,bill_id,
            min(invoice_id) invoice_id,min(payment_method_id) payment_method_id, min(client_id) client_id,
            min(subscriber_id) subscriber_id, min(payment_date) payment_date, min(confirmation_date) confirmation_date,
            sum(amount) amount, sum(surcharge) surcharge, min(client_bank_account_id) client_bank_account_id,
            min(charge_account_id) charge_account_id, min(created_at) created_at, min(updated_at) updated_at,
            min(created_by) created_by, min(updated_by) updated_by, min(sepa_return_code_id) sepa_return_code_id")
    .where(id: cp).in_bank.group(:bill_id)
  }

  # Callbacks
  # before_save :check_debt
  after_save :reindex_instalment
  after_destroy :reindex_instalment

  #
  # Methods
  #
  def full_no
    # Receipt no (Office & year & sequential number) => OOOO-YYYY-NNNNN
    receipt_no.blank? ? "" : receipt_no.length < 13 ? receipt_no : receipt_no[0..3] + '-' + receipt_no[4..7] + '-' + receipt_no[8..12]
  end

  # 9 digits Id for bank orders
  def full_id
    self.id.blank? ? '000000000' : self.id.to_s.rjust(9,'0')
  end

  def total
    amount + surcharge
  end

  def instalment_invoices
    instalment.instalment_invoices if instalment
  end

  def subscriber_name
    !self.subscriber.blank? ? self.subscriber.full_name.strip : ''
  end

  def sanitized_subscriber_name
    sanitize_string(subscriber_name, true, true, true, false)
  end

  def subscriber_address
    !self.subscriber.blank? ? self.subscriber.address_1.strip : ''
  end

  def sanitized_subscriber_address
    sanitize_string(subscriber_address, true, true, true, false)
  end

  def client_name
    !self.client.blank? ? self.client.name.strip : ''
  end

  def sanitized_client_name
    sanitize_string(client_name, true, true, true, false)
  end

  def client_address
    !self.client.blank? ? self.client.address_1.strip : ''
  end

  def sanitized_client_address
    sanitize_string(client_address, true, true, true, false)
  end

  def client_bank_account_iban
    !self.client_bank_account.blank? ? self.client_bank_account.e_format : ''
  end

  def client_bank_account_swift
    !self.client_bank_account.blank? ? self.client_bank_account.swift : ''
  end

  def client_bank_account_start
    !self.client_bank_account.blank? ? self.client_bank_account.starting_at.strftime("%Y-%m-%d") : ''
  end

  def client_bank_account_holder
    !self.client_bank_account.blank? ? self.client_bank_account.holder_name.strip : ''
  end

  def sanitized_client_bank_account_holder
    sanitize_string(client_bank_account_holder, true, true, true, false)
  end

  def client_bank_account_refere
    !self.client_bank_account.blank? ? self.client_bank_account.refere.to_s.strip : ''
  end

  #encrypted security code
  def burst_security
    fact = self.bill.raw_invoice_based_no
    date = formatted_timestamp(self.bill.bill_date)
    userid = self.created_by.to_s
    collected = self.bill.collected.round(2)
    ci = collected.to_i
    cr = (collected - ci).to_s
    crl = cr.length
    crr = (cr[2..crl]).ljust(2,"0")
    collected = ci.to_s + crr
    security_no = fact + date + userid + collected
    # hashed_password = BCrypt::Password.create("AES332017005242830/05/201700:00:00003300246623891")
    Digest::MD5.hexdigest(security_no)
  end

  # Payment method used in collection
  def real_payment_method_name
    payment_method.to_label rescue ''
  end
  def real_payment_method_code
    payment_method.code rescue ''
  end

  #
  # CSV
  #
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
  def self.to_csv(array)
    attributes = [array[0].sanitize("Id"),
                  array[0].sanitize(I18n.t("activerecord.attributes.client_payment.receipt_no")),
                  array[0].sanitize(I18n.t("activerecord.attributes.subscriber.invoice_number")),
                  array[0].sanitize(I18n.t('activerecord.attributes.client_payment.payment_date')),
                  array[0].sanitize(I18n.t('ag2_gest.bills.index.confirmation_date_c')),
                  array[0].sanitize(I18n.t('activerecord.attributes.report.client_code')),
                  array[0].sanitize(I18n.t('activerecord.attributes.client_payment.charged')),
                  array[0].sanitize(I18n.t('activerecord.models.instalment_plan.one')),
                  array[0].sanitize(I18n.t('activerecord.attributes.client_payment.amount')),
                  array[0].sanitize(I18n.t('activerecord.attributes.client_payment.total'))]

    col_sep = I18n.locale == :es ? ";" : ","
    CSV.generate(headers: true, col_sep: col_sep, row_sep: "\r\n") do |csv|
      csv << attributes
      array.each do |cp|
        date = cp.formatted_date(cp.payment_date) unless cp.payment_date.blank?
        date_confirm = cp.formatted_date(cp.confirmation_date) unless cp.confirmation_date.blank?
        full_subscriber = ""
        if !cp.subscriber.blank?
          full_subscriber += cp.subscriber.full_name_or_company_and_code.to_s
        else
          full_subscriber += cp.client.full_name_or_company_and_code.to_s
        end
        payment_type = PaymentType.code_with_param(cp.payment_type)
        amount = cp.number_with_precision(cp.amount, precision: 2, delimiter: I18n.locale == :es ? "." : ",") unless cp.amount.blank?
        if cp.instalment_id.blank?
          total = cp.number_with_precision(cp.invoice.receivables, precision: 2, delimiter: I18n.locale == :es ? "." : ",") unless cp.invoice.blank?
          instalment = ""
        else
          total = cp.number_with_precision(cp.instalment.amount, precision: 2, delimiter: I18n.locale == :es ? "." : ",") unless cp.instalment.blank?
          instalment = cp.instalment.partial_instalment_no unless cp.instalment_id.blank?
        end
        csv << [  cp.id,
                  cp.full_no,
                  cp.try(:invoice).try(:old_no_based_real_no),
                  date,
                  date_confirm,
                  full_subscriber,
                  payment_type,
                  instalment,
                  amount,
                  total]
      end
    end
  end

  searchable do
    text :receipt_no
    integer :payment_type
    integer :id
    date :confirmation_date
    date :created_at
    integer :created_by
    string :receipt_no, :multiple => true   # Multiple search values accepted in one search (inverse_no_search)
    string :client_code_name_fiscal, :multiple => true do
      bill.client.full_name_or_company_code_fiscal unless (bill.blank? || bill.client.blank?)
    end
    string :subscriber_code_name_fiscal, :multiple => true do
      bill.subscriber.code_full_name_or_company_fiscal unless (bill.blank? || bill.subscriber.blank?)
    end
    string :supply_address, :multiple => true do
      bill.subscriber.subscriber_supply_address.supply_address unless (bill.subscriber.blank? || bill.subscriber.subscriber_supply_address.blank? || bill.subscriber.subscriber_supply_address.supply_address.blank?)
    end
    string :bill_no, :multiple => true do     # Multiple search values accepted in one search (inverse_no_search)
      bill.bill_no unless (bill.blank? || bill.bill_no.blank?)
    end
    string :invoice_no, :multiple => true do  # Multiple search values accepted in one search (inverse_no_search)
      invoice.invoice_no unless (invoice.blank? || invoice.invoice_no.blank?)
    end
    integer :client_id
    integer :subscriber_id
    integer :client_ids, :multiple => true do
      client_id
    end
    integer :subscriber_ids, :multiple => true do
      subscriber_id unless subscriber_id.blank?
    end
    integer :project_id, :multiple => true do
      bill.project_id unless (bill.blank? || bill.project_id.blank?)
    end
    boolean :bank_account do
      bill.client.active_bank_accounts? unless (bill.blank? || bill.client.blank?)
    end
    integer :billing_period_id do
      bill.reading_2.nil? ? nil : bill.reading_2.billing_period_id
    end
    string :sort_no do
      bill.bill_no
    end
  end

  private

  # Can't collect more than the current debt
  def check_debt
    invoice_debt = invoice.debt
    if invoice_debt >= 0 && amount > invoice_debt
      errors.add(:base, I18n.t('activerecord.models.client_payment.check_debt'))
      return false
    end
  end

  def reindex_instalment
    Sunspot.index(instalment_invoices) if instalment
  end
end
