class CreateViewSaleOfferItemBalance < ActiveRecord::Migration
  def up
    execute 'create view sale_offer_item_balances as
    select `sale_offer_items`.`id` AS `sale_offer_item_id`,`sale_offer_items`.`quantity` AS `sale_offer_item_quantity`,coalesce(sum(`invoice_items`.`quantity`),0) AS `invoiced_quantity`,(`sale_offer_items`.`quantity` - coalesce(sum(`invoice_items`.`quantity`),0)) AS `balance` from (`sale_offer_items` left join `invoice_items` on((`sale_offer_items`.`id` = `invoice_items`.`sale_offer_item_id`))) group by `sale_offer_items`.`id`'
  end

  def down
    execute 'drop view sale_offer_item_balances'
  end
end
