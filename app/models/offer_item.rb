class OfferItem < ActiveRecord::Base
  belongs_to :offer
  belongs_to :product
  belongs_to :tax_type
  attr_accessible :code, :delivery_date, :description, :discount, :discount_pct, :price, :quantity,
                  :offer_id, :product_id, :tax_type_id
end
