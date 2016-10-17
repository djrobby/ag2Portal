class InvoiceType < ActiveRecord::Base
  # CONSTANTS
  WATER = 1
  TCA = 2
  CONTRACT = 3
  OTHER = 4
  COMMERCIAL = 5

	has_many :invoices

  attr_accessible :name

end
