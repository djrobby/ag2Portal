class CreateViewSupplierInvoicePayment < ActiveRecord::Migration
  def up
    execute 'create view supplier_invoice_payments as
    select `supplier_payments`.`supplier_invoice_id`,coalesce(sum(`supplier_payments`.`amount`),0) AS `paid`
    from `supplier_payments` group by `supplier_payments`.`supplier_invoice_id`'
  end

  def down
    execute 'drop view supplier_invoice_payments'
  end
end
