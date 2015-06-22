class InventoryCountItem < ActiveRecord::Base
  belongs_to :inventory_count
  belongs_to :product
  attr_accessible :quantity, :inventory_count_id, :product_id

  has_paper_trail

  validates :product, :presence => true
end
