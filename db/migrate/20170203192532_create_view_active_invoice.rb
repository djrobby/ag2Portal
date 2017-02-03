class CreateViewActiveInvoice < ActiveRecord::Migration
  def up
    execute 'create view active_invoices as
    SELECT invoices.billing_period_id,bills.client_id,bills.subscriber_id,invoices.invoice_type_id,
    invoices.invoice_operation_id,bills.id AS bill_id,invoices.id AS invoice_id,invoices.original_invoice_id
    FROM invoices
    JOIN bills ON invoices.bill_id=bills.id
    WHERE (invoice_operation_id=1 OR invoice_operation_id=3)
    AND invoices.id NOT IN
    (SELECT original_invoice_id FROM invoices WHERE (invoice_operation_id=2 OR invoice_operation_id=4))'
  end

  def down
    execute 'drop view active_invoices'
  end
end
