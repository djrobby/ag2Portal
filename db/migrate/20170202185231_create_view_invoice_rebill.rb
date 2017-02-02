class CreateViewInvoiceRebill < ActiveRecord::Migration
  def up
    execute 'create view invoice_rebills as
    select `invoices`.`id` AS `invoice_id`,`invoices`.`organization_id` AS `organization_id`,`bills`.`project_id` AS `project_id`,
    `bills`.`client_id` AS `client_id`,`bills`.`subscriber_id` AS `subscriber_id`,`invoices`.`billing_period_id` AS `billing_period_id`,
    `invoices`.`invoice_no` AS `invoice_no`,`invoices`.`invoice_date` AS `invoice_date`,
    coalesce(sum((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`))),0) AS `subtotal`,
    (case when ((`invoices`.`discount_pct` = 0) or isnull(`invoices`.`discount_pct`)) then coalesce(sum(((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`)) * (`tax_types`.`tax` / 100))),0) else (coalesce(sum(((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`)) * (`tax_types`.`tax` / 100))),0) * (`invoices`.`discount_pct` / 100)) end) AS `taxes`,
    (case when ((`invoices`.`discount_pct` = 0) or isnull(`invoices`.`discount_pct`)) then 0 else (coalesce(sum((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`))),0) * (`invoices`.`discount_pct` / 100)) end) AS `bonus`,
    (case when ((`invoices`.`discount_pct` = 0) or isnull(`invoices`.`discount_pct`)) then coalesce(sum((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`))),0) else (coalesce(sum((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`))),0) - (coalesce(sum((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`))),0) * (`invoices`.`discount_pct` / 100))) end) AS `taxable`,
    (case when ((`invoices`.`discount_pct` = 0) or isnull(`invoices`.`discount_pct`)) then (coalesce(sum((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`))),0) + coalesce(sum(((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`)) * (`tax_types`.`tax` / 100))),0)) else ((coalesce(sum((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`))),0) - (coalesce(sum((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`))),0) * (`invoices`.`discount_pct` / 100))) + (coalesce(sum(((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`)) * (`tax_types`.`tax` / 100))),0) * (`invoices`.`discount_pct` / 100))) end) AS `total`,
    `invoices`.`original_invoice_id` AS `original_invoice_id`
    from ((`invoices` join `invoice_items` on((`invoices`.`id` = `invoice_items`.`invoice_id`))) join `tax_types` on((`invoice_items`.`tax_type_id` = `tax_types`.`id`)) join `bills` on((`invoices`.`bill_id` = `bills`.`id`)))
    where `invoices`.`invoice_operation_id`=3 group by `invoices`.`id`'
  end

  def down
    execute 'drop view invoice_rebills'
  end
end
