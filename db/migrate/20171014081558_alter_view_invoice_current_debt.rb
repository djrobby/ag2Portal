class AlterViewInvoiceCurrentDebt < ActiveRecord::Migration
  def change
    execute 'alter view invoice_current_debts as
    select `invoices`.`id` AS `invoice_id`,`invoices`.`organization_id` AS `organization_id`,`invoices`.`bill_id` AS `bill_id`,
    `invoices`.`invoice_status_id` AS `invoice_status_id`,`invoices`.`invoice_type_id` AS `invoice_type_id`,`invoices`.`invoice_operation_id` AS `invoice_operation_id`,
    `bills`.`client_id` AS `client_id`,`bills`.`subscriber_id` AS `subscriber_id`,`bills`.`project_id` AS `project_id`,`projects`.`office_id` AS `office_id`,
    `invoices`.`invoice_no` AS `invoice_no`,`invoices`.`invoice_date` AS `invoice_date`,`invoices`.`payday_limit` AS `payday_limit`,
    coalesce(sum((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`))),0) AS `subtotal`,
    (case when ((`invoices`.`discount_pct` = 0) or isnull(`invoices`.`discount_pct`)) then coalesce(sum(((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`)) * (`tax_types`.`tax` / 100))),0) else (coalesce(sum(((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`)) * (`tax_types`.`tax` / 100))),0) * (`invoices`.`discount_pct` / 100)) end) AS `taxes`,
    (case when ((`invoices`.`discount_pct` = 0) or isnull(`invoices`.`discount_pct`)) then 0 else (coalesce(sum((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`))),0) * (`invoices`.`discount_pct` / 100)) end) AS `bonus`,
    (case when ((`invoices`.`discount_pct` = 0) or isnull(`invoices`.`discount_pct`)) then coalesce(sum((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`))),0) else (coalesce(sum((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`))),0) - (coalesce(sum((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`))),0) * (`invoices`.`discount_pct` / 100))) end) AS `taxable`,
    (case when ((`invoices`.`discount_pct` = 0) or isnull(`invoices`.`discount_pct`)) then (coalesce(sum((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`))),0) + coalesce(sum(((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`)) * (`tax_types`.`tax` / 100))),0)) else ((coalesce(sum((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`))),0) - (coalesce(sum((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`))),0) * (`invoices`.`discount_pct` / 100))) + (coalesce(sum(((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`)) * (`tax_types`.`tax` / 100))),0) * (`invoices`.`discount_pct` / 100))) end) AS `total`,
    coalesce(`invoice_payments`.`paid`,0) AS `paid`,
    (case when ((`invoices`.`discount_pct` = 0) or isnull(`invoices`.`discount_pct`)) then ((coalesce(sum((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`))),0) + coalesce(sum(((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`)) * (`tax_types`.`tax` / 100))),0)) - coalesce(`invoice_payments`.`paid`,0)) else (((coalesce(sum((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`))),0) - (coalesce(sum((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`))),0) * (`invoices`.`discount_pct` / 100))) + (coalesce(sum(((`invoice_items`.`quantity` * (`invoice_items`.`price` - `invoice_items`.`discount`)) * (`tax_types`.`tax` / 100))),0) * (`invoices`.`discount_pct` / 100))) - coalesce(`invoice_payments`.`paid`,0)) end) AS `calc_debt`,
    coalesce(`invoices`.`totals`,0) AS `totals`,
    coalesce(`invoices`.`receivables`,0) AS `receivables`,
    (coalesce(`invoices`.`receivables`,0) - coalesce(`invoice_payments`.`paid`,0)) AS `debt`
    from (((`invoices` join `invoice_items` on((`invoices`.`id` = `invoice_items`.`invoice_id`))) join `tax_types` on((`invoice_items`.`tax_type_id` = `tax_types`.`id`)) join (`bills` join `projects` on `bills`.`project_id` = `projects`.`id`) on((`invoices`.`bill_id` = `bills`.`id`)))
    left join `invoice_payments` on((`invoice_payments`.`invoice_id` = `invoices`.`id`)))
    group by `invoices`.`id` having (`debt` <> 0)'
  end
end
