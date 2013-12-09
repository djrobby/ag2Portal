class OfferRequestItem < ActiveRecord::Base
  belongs_to :offer_request
  belongs_to :product
  belongs_to :tax_type
  attr_accessible :description, :price, :quantity,
                  :offer_request_id, :product_id, :tax_type_id
end
