class InvoiceStatus < ActiveRecord::Base
  attr_accessible :name

  has_many :bills
  has_many :invoices
end
