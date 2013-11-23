class PurchaseOrderItem < ActiveRecord::Base
  belongs_to :purchase_order
  belongs_to :product
  belongs_to :tax_type
  attr_accessible :code, :delivery_date, :description, :discount, :discount_pct, :quantity,
                  :price, :purchase_order_id, :product_id, :tax_type_id

  has_paper_trail

  validates :description,       :presence => true
  validates :purchase_order_id, :presence => true
  validates :product_id,        :presence => true
  validates :tax_type_id,       :presence => true
end
