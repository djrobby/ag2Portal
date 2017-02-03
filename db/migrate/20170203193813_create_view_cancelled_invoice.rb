class CreateViewCancelledInvoice < ActiveRecord::Migration
  def up
    execute 'create view cancelled_invoices as
    SELECT invoices.billing_period_id,bills.client_id,bills.subscriber_id,invoices.invoice_type_id,
    invoices.invoice_operation_id,bills.id AS bill_id,invoices.id AS invoice_id,invoices.original_invoice_id,
    c.id AS credit_invoice_id
    FROM invoices
    JOIN bills ON invoices.bill_id=bills.id
    JOIN invoices c ON invoices.id=c.original_invoice_id AND (c.invoice_operation_id=2 OR c.invoice_operation_id=4)
    WHERE (invoices.invoice_operation_id=1 OR invoices.invoice_operation_id=3)'
  end

  def down
    execute 'drop view cancelled_invoices'
  end
end
