class InstalmentInvoice < ActiveRecord::Base
  belongs_to :instalment
  belongs_to :bill
  belongs_to :invoice
  attr_accessible :amount, :debt, :instalment_id, :bill_id, :invoice_id
end
