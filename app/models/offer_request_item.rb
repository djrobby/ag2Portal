class OfferRequestItem < ActiveRecord::Base
  belongs_to :offer_request
  belongs_to :product
  belongs_to :tax_type
  attr_accessible :description, :price, :quantity,
                  :offer_request_id, :product_id, :tax_type_id

  has_paper_trail

  validates :description,   :presence => true
  validates :offer_request, :presence => true
  validates :product,       :presence => true
  validates :tax_type,      :presence => true
end
