class AlterAgainViewInvoiceDebt < ActiveRecord::Migration
  def change
    execute 'alter view invoice_debts as
    select `invoices`.`id` AS `invoice_id`,`invoices`.`organization_id` AS `organization_id`,`invoices`.`bill_id` AS `bill_id`,
    `invoices`.`invoice_status_id` AS `invoice_status_id`,`invoices`.`invoice_type_id` AS `invoice_type_id`,`invoices`.`invoice_operation_id` AS `invoice_operation_id`,
    `bills`.`client_id` AS `client_id`,`bills`.`subscriber_id` AS `subscriber_id`,`bills`.`project_id` AS `project_id`,`projects`.`office_id` AS `office_id`,
    `invoices`.`invoice_no` AS `invoice_no`,`invoices`.`invoice_date` AS `invoice_date`,`invoices`.`payday_limit` AS `payday_limit`,
    coalesce(`invoices`.`subtotals`,0) AS `subtotal`,
    coalesce(`invoices`.`total_taxes`,0) AS `taxes`,
    coalesce(`invoices`.`bonuses`,0) AS `bonus`,
    coalesce(`invoices`.`taxables`,0) AS `taxable`,
    coalesce(`invoices`.`totals`,0) AS `total`,
    coalesce(`invoice_payments`.`paid`,0) AS `paid`,
    (coalesce(`invoices`.`receivables`,0) - coalesce(`invoice_payments`.`paid`,0)) AS `calc_debt`,
    coalesce(`invoices`.`totals`,0) AS `totals`,
    coalesce(`invoices`.`receivables`,0) AS `receivables`,
    (coalesce(`invoices`.`receivables`,0) - coalesce(`invoice_payments`.`paid`,0)) AS `debt`
    from `invoices` join (`bills` join `projects` on `bills`.`project_id` = `projects`.`id`) on `invoices`.`bill_id` = `bills`.`id`
    left join `invoice_payments` on `invoice_payments`.`invoice_id` = `invoices`.`id`
    group by `invoices`.`id` -- having (`debt` <> 0)'
  end
end
