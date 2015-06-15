class CreateViewPurchaseOrderItemBalance < ActiveRecord::Migration
  def up
    execute 'create view purchase_order_item_balances as 
    select `purchase_order_items`.`id` AS `purchase_order_item_id`,`purchase_order_items`.`quantity` AS `purchase_order_item_quantity`,coalesce(sum(`receipt_note_items`.`quantity`),0) AS `receipt_quantity`,(`purchase_order_items`.`quantity` - coalesce(sum(`receipt_note_items`.`quantity`),0)) AS `balance` from (`purchase_order_items` left join `receipt_note_items` on((`purchase_order_items`.`id` = `receipt_note_items`.`purchase_order_item_id`))) group by `purchase_order_items`.`id`'
  end

  def down
    execute 'drop view purchase_order_item_balances'
  end
end
