class PaymentMethodLedgerAccount < ActiveRecord::Base
  belongs_to :payment_method
  belongs_to :input_ledger_account, class_name: 'LedgerAccount'
  belongs_to :output_ledger_account, class_name: 'LedgerAccount'
  belongs_to :company

  attr_accessor :thing
  attr_accessible :payment_method_id, :input_ledger_account_id, :output_ledger_account_id, :company_id, :thing

  has_paper_trail

  validates :input_ledger_account,  :presence => true   # For charges/collections
  validates :output_ledger_account, :presence => true   # For payments
end
