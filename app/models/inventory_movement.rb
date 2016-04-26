class InventoryMovement < ActiveRecord::Base
  belongs_to :store
  belongs_to :product
  attr_accessible :item_id, :mdate, :parent_id, :price, :quantity, :type,
                  :store_id, :product_id
end
