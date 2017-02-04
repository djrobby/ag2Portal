class ActiveSupplyInvoice < ActiveRecord::Base
  belongs_to :invoice
  belongs_to :bill
  belongs_to :client
  belongs_to :subscriber
  belongs_to :billing_period
  belongs_to :invoice_type
  belongs_to :invoice_operation
  belongs_to :pre_invoice

  attr_accessible :invoice_id, :bill_id, :client_id, :subscriber_id, :billing_period_id,
                  :invoice_type_id, :invoice_operation_id, :original_invoice_id, :pre_invoice_id
end
