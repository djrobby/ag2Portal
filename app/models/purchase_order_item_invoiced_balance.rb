class PurchaseOrderItemInvoicedBalance < ActiveRecord::Base
  belongs_to :purchase_order_item
  attr_accessible :purchase_order_item_id, :purchase_order_item_quantity, :invoiced_quantity, :balance
end
