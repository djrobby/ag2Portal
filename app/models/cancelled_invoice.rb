#
# ES: Facturas abonadas (originales o refacturas que tienen una adicional de abono, total o parcial)
#
class CancelledInvoice < ActiveRecord::Base
  belongs_to :invoice
  belongs_to :bill
  belongs_to :client
  belongs_to :subscriber
  belongs_to :billing_period
  belongs_to :invoice_type
  belongs_to :invoice_operation

  attr_accessible :invoice_id, :bill_id, :client_id, :subscriber_id, :billing_period_id,
                  :invoice_type_id, :invoice_operation_id, :original_invoice_id, :credit_invoice_id
end
