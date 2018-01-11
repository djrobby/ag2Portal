class PurchaseOrderItemBalance < ActiveRecord::Base
  belongs_to :purchase_order_item
  attr_accessible :purchase_order_item_id, :purchase_order_item_quantity, :receipt_quantity, :balance

  def delay
    d = 0
    if balance > 0
      d = (Time.now.to_date - purchase_order_item.purchase_order.order_date).to_i
    end
    d
  end
end
