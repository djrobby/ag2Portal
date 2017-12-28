class InstalmentInvoice < ActiveRecord::Base
  belongs_to :instalment
  belongs_to :bill
  belongs_to :invoice
  attr_accessible :amount, :debt, :instalment_id, :bill_id, :invoice_id

  validates :bill,    :presence => true
  validates :invoice, :presence => true

  searchable do
    string :bill_no, :multiple => true do   # Multiple search values accepted in one search (inverse_no_search)
      bill.bill_no unless bill.blank?
    end
    string :invoice_no, :multiple => true do   # Multiple search values accepted in one search (inverse_no_search)
      invoice.invoice_no unless invoice.blank?
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
    boolean :bank_account do
      bill.client.active_bank_accounts? unless (bill.blank? || bill.client.blank?)
    end
    integer :billing_period_id do
      bill.reading_2.nil? ? nil : bill.reading_2.billing_period_id
    end
    integer :created_by do
      instalment.created_by unless (instalment.blank? || instalment.created_by.blank?)
    end
    string :sort_no do
      bill.bill_no
    end
  end
end
