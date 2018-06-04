class InstalmentInvoice < ActiveRecord::Base
  belongs_to :instalment
  belongs_to :bill
  belongs_to :invoice
  attr_accessible :amount, :debt, :instalment_id, :bill_id, :invoice_id

  validates :bill,    :presence => true
  validates :invoice, :presence => true

  has_one :instalment_plan, through: :instalment

  #
  # Methods
  #
  def instalment_date
    instalment_plan.instalment_date rescue nil
  end

  # Instalment payday limit
  def instalment_payday_limit
    instalment.payday_limit rescue nil
  end

  # Invoice date
  def invoice_date
    invoice.invoice_date rescue nil
  end

  # Invoice payday limit
  def invoice_payday_limit
    invoice.payday_limit rescue nil
  end

  def biller_id
    invoice.biller_id rescue nil
  end

  # Sunspot searchable
  searchable do
    string :bill_no, :multiple => true do   # Multiple search values accepted in one search (inverse_no_search)
      bill.bill_no unless bill.blank?
    end
    string :invoice_no, :multiple => true do   # Multiple search values accepted in one search (inverse_no_search)
      invoice.invoice_no unless invoice.blank?
    end
    string :raw_bill_no, :multiple => true do   # Multiple search values accepted in one search (inverse_no_search)
      bill.raw_invoice_based_no unless (bill.blank? || bill.bill_no.blank?)
    end
    string :raw_invoice_no, :multiple => true do   # Multiple search values accepted in one search (inverse_no_search)
      invoice.raw_invoice_no unless (invoice.blank? || invoice.invoice_no.blank?)
    end
    string :client_code_name_fiscal, :multiple => true do
      bill.client.full_name_or_company_code_fiscal unless (bill.blank? || bill.client.blank?)
    end
    string :subscriber_code_name_fiscal, :multiple => true do
      bill.subscriber.code_full_name_or_company_fiscal unless (bill.blank? || bill.subscriber.blank?)
    end
    string :supply_address, :multiple => true do
      bill.subscriber.subscriber_supply_address.supply_address unless (bill.subscriber.blank? || bill.subscriber.subscriber_supply_address.blank? || bill.subscriber.subscriber_supply_address.supply_address.blank?)
    end
    integer :client_payment do
      instalment.client_payment.id unless (instalment.blank? || instalment.client_payment.blank?)
    end
    integer :project_id, :multiple => true do
      bill.project_id unless (bill.blank? || bill.project_id.blank?)
    end
    integer :client_id do
      bill.client_id unless (bill.blank? || bill.client_id.blank?)
    end
    integer :subscriber_id do
      bill.subscriber_id unless (bill.blank? || bill.subscriber_id.blank?)
    end
    integer :biller_id do
      biller_id
    end
    integer :client_ids, :multiple => true do
      bill.client_id unless (bill.blank? || bill.client_id.blank?)
    end
    integer :subscriber_ids, :multiple => true do
      bill.subscriber_id unless (bill.blank? || bill.subscriber_id.blank?)
    end
    boolean :bank_account do
      bill.client.active_bank_accounts? unless (bill.blank? || bill.client.blank?)
    end
    integer :billing_period_id do
      bill.reading_2.nil? ? nil : bill.reading_2.billing_period_id
    end
    integer :created_by do
      instalment.created_by unless (instalment.blank? || instalment.created_by.blank?)
    end
    date :instalment_date do
      instalment_date
    end
    date :instalment_payday_limit do
      instalment_payday_limit
    end
    date :invoice_date do
      invoice_date
    end
    date :invoice_payday_limit do
      invoice_payday_limit
    end
    string :sort_no do
      bill.bill_no
    end
  end
end
