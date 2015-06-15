class CreateViewReceiptNoteItemBalance < ActiveRecord::Migration
  def up
    execute 'create view receipt_note_item_balances as 
    select `receipt_note_items`.`id` AS `receipt_note_item_id`,`receipt_note_items`.`quantity` AS `receipt_note_item_quantity`,coalesce(sum(`supplier_invoice_items`.`quantity`),0) AS `invoiced_quantity`,(`receipt_note_items`.`quantity` - coalesce(sum(`supplier_invoice_items`.`quantity`),0)) AS `balance` from (`receipt_note_items` left join `supplier_invoice_items` on((`receipt_note_items`.`id` = `supplier_invoice_items`.`receipt_note_item_id`))) group by `receipt_note_items`.`id`'
  end

  def down
    execute 'drop view receipt_note_item_balances'
  end
end
