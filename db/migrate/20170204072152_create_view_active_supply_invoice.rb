class CreateViewActiveSupplyInvoice < ActiveRecord::Migration
  def up
    execute 'create view active_supply_invoices as
    SELECT active_invoices.*,pre_invoices.id AS pre_invoice_id FROM active_invoices
    JOIN pre_invoices ON active_invoices.invoice_id=pre_invoices.invoice_id
    WHERE active_invoices.invoice_type_id=1'
  end

  def down
    execute 'drop view active_supply_invoices'
  end
end
