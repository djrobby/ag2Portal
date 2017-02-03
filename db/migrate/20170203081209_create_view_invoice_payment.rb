class CreateViewInvoicePayment < ActiveRecord::Migration
  def up
    execute 'create view invoice_payments as
    select `client_payments`.`invoice_id`,coalesce(sum(`client_payments`.`amount`),0) AS `paid`
    from `client_payments` group by `client_payments`.`invoice_id`'
  end

  def down
    execute 'drop view invoice_payments'
  end
end
