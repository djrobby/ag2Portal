class CreateViewInvoiceDebt < ActiveRecord::Migration
  def up
    execute 'create view invoice_debts as
    select `invoices`.`id` AS `invoice_id`,`invoices`.`organization_id` AS `organization_id`,`bills`.`client_id` AS `client_id`,`invoices`.`invoice_no` AS `invoice_no`,
    coalesce(sum((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`))),0) AS `subtotal`,
    (case when ((`invoices`.`discount_pct` = 0) or isnull(`invoices`.`discount_pct`)) then coalesce(sum(((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`)) * (`tax_types`.`tax` / 100))),0) else (coalesce(sum(((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`)) * (`tax_types`.`tax` / 100))),0) * (`invoices`.`discount_pct` / 100)) end) AS `taxes`,
    (case when ((`invoices`.`discount_pct` = 0) or isnull(`invoices`.`discount_pct`)) then 0 else (coalesce(sum((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`))),0) * (`invoices`.`discount_pct` / 100)) end) AS `bonus`,
    (case when ((`invoices`.`discount_pct` = 0) or isnull(`invoices`.`discount_pct`)) then coalesce(sum((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`))),0) else (coalesce(sum((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`))),0) - (coalesce(sum((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`))),0) * (`invoices`.`discount_pct` / 100))) end) AS `taxable`,
    (case when ((`invoices`.`discount_pct` = 0) or isnull(`invoices`.`discount_pct`)) then (coalesce(sum((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`))),0) + coalesce(sum(((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`)) * (`tax_types`.`tax` / 100))),0)) else ((coalesce(sum((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`))),0) - (coalesce(sum((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`))),0) * (`invoices`.`discount_pct` / 100))) + (coalesce(sum(((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`)) * (`tax_types`.`tax` / 100))),0) * (`invoices`.`discount_pct` / 100))) end) AS `total`,
    coalesce(`invoice_payments`.`paid`,0) AS `paid`,
    (case when ((`invoices`.`discount_pct` = 0) or isnull(`invoices`.`discount_pct`)) then ((coalesce(sum((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`))),0) + coalesce(sum(((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`)) * (`tax_types`.`tax` / 100))),0)) - coalesce(`invoice_payments`.`paid`,0)) else (((coalesce(sum((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`))),0) - (coalesce(sum((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`))),0) * (`invoices`.`discount_pct` / 100))) + (coalesce(sum(((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`)) * (`tax_types`.`tax` / 100))),0) * (`invoices`.`discount_pct` / 100))) - coalesce(`invoice_payments`.`paid`,0)) end) AS `debt`
    from (((`invoices` join `invoice_items` on((`invoices`.`id` = `invoice_items`.`invoice_id`))) join `tax_types` on((`invoice_items`.`tax_type_id` = `tax_types`.`id`)) join `bills` on((`invoices`.`bill_id` = `bills`.`id`)))
    left join `invoice_payments` on((`invoice_payments`.`invoice_id` = `invoices`.`id`)))
    group by `invoices`.`id` -- having (`debt` <> 0)'
  end

  def down
    execute 'drop view invoice_debts'
  end
end
