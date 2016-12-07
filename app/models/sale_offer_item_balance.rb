class SaleOfferItemBalance < ActiveRecord::Base
  belongs_to :sale_offer_item
  attr_accessible :sale_offer_item_id, :sale_offer_item_quantity, :invoiced_quantity, :balance
end
