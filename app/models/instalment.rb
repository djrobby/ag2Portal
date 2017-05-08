class Instalment < ActiveRecord::Base
  belongs_to :instalment_plan
  # belongs_to :bill
  # belongs_to :invoice
  attr_accessible :amount, :instalment, :payday_limit, :surcharge,
                  :instalment_plan_id#, :bill_id, :invoice_id

  has_one :client_payment
  has_many :instalment_invoices, dependent: :destroy
  has_many :bills, through: :instalment_invoices
  has_many :invoices, through: :instalment_invoices

  # validates :code,  :presence => true
  # validates :name,  :presence => true
  # validates :type,  :presence => true

  # Callbacks
  before_destroy :check_for_dependent_records

  #
  # Calculated fields
  #
  def total
    amount + surcharge
  end

  def amount_collected
    client_payment.blank? ? 0 : client_payment.amount
  end

  def surcharge_collected
    client_payment.blank? ? 0 : client_payment.surcharge
  end

  def amount_debt
    amount - amount_collected
  end

  def surcharge_debt
    surcharge - surcharge_collected
  end

  def debt
    amount_debt + surcharge_debt
  end

  # searchable do
  #   string :bill_no, :multiple => true do   # Multiple search values accepted in one search (inverse_no_search)
  #     bill.bill_no unless bill.blank?
  #   end
  #   string :client_code_name_fiscal, :multiple => true do
  #     bill.client.full_name_or_company_code_fiscal unless (bill.blank? || bill.client.blank?)
  #   end
  #   string :subscriber_code_name_fiscal, :multiple => true do
  #     bill.subscriber.code_full_name_or_company_fiscal unless (bill.blank? || bill.subscriber.blank?)
  #   end
  #   string :supply_address, :multiple => true do
  #     bill.subscriber.subscriber_supply_address.supply_address unless (bill.subscriber.blank? || bill.subscriber.subscriber_supply_address.blank? || bill.subscriber.subscriber_supply_address.supply_address.blank?)
  #   end
  #   integer :client_payment do
  #     client_payment.id unless client_payment.blank?
  #   end
  #   integer :project_id, :multiple => true do
  #     bill.project_id unless (bill.blank? || bill.project_id.blank?)
  #   end
  #   integer :client_id do
  #     bill.client_id
  #   end
  #   integer :subscriber_id do
  #     bill.subscriber_id
  #   end
  #   boolean :bank_account do
  #     bill.client.active_bank_accounts? unless (bill.blank? || bill.client.blank?)
  #   end
  #   integer :billing_period_id do
  #     bill.reading_2.nil? ? nil : bill.reading_2.billing_period_id
  #   end
  #   string :sort_no do
  #     bill.bill_no
  #   end
  # end

  private

  def check_for_dependent_records
    # Check for client payments
    if client_payments.count > 0
      errors.add(:base, I18n.t('activerecord.models.supplier.check_for_client_payments'))
      return false
    end
  end
end
