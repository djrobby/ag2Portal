class InvoiceOperation < ActiveRecord::Base
  # CONSTANTS
  INVOICE = 1
  CANCELATION = 2
  REINVOICE = 3
  PAYMENT = 4

  attr_accessible :name

  has_many :invoices
end
