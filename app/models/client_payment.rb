class ClientPayment < ActiveRecord::Base
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
  attr_accessible :receipt_no, :payment_type, :payment_date, :confirmation_date, :amount, :surcharge,
                  :bill_id, :invoice_id, :client_id, :client_bank_account_id, :subscriber_id,
                  :instalment_id, :charge_account_id, :payment_method_id

  validates :bill,              :presence => true
  validates :invoice,           :presence => true
  validates :payment_method,    :presence => true

  # Callbacks
  after_save :reindex_instalment
  after_destroy :reindex_instalment

  def full_no
    # Receipt no (Office & year & sequential number) => OO-YYYY-NNNN
    receipt_no.blank? ? "" : receipt_no[0.1] + '-' + receipt_no[2..5] + '-' + receipt_no[6..9]
  end

  def instalment_invoices
    instalment.instalment_invoices if instalment
  end

  searchable do
    text :receipt_no
    integer :payment_type
    integer :id
    date :confirmation_date
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
    integer :client_id do
      bill.client_id unless (bill.blank? || bill.client_id.blank?)
    end
    integer :subscriber_id do
      bill.subscriber_id unless (bill.blank? || bill.subscriber_id.blank?)
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

  def reindex_instalment
    Sunspot.index(instalment_invoices) if instalment
  end
end
