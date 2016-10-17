class InvoiceStatus < ActiveRecord::Base
  # CONSTANTS
  PENDING = 1
  CASH = 2
  BANK = 3
  REFUND = 4
  FRACTIONATED = 5
  CHARGED = 99

  attr_accessible :name

  has_many :bills
  has_many :invoices

end
