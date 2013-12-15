class OfferItem < ActiveRecord::Base
  belongs_to :offer
  belongs_to :product
  belongs_to :tax_type
  attr_accessible :code, :delivery_date, :description, :discount, :discount_pct, :price, :quantity,
                  :offer_id, :product_id, :tax_type_id

  has_paper_trail

  validates :description, :presence => true
  validates :offer,       :presence => true
  validates :product,     :presence => true
  validates :tax_type,    :presence => true
end
