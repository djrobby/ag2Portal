class WorkOrderItem < ActiveRecord::Base
  belongs_to :work_order
  belongs_to :product
  belongs_to :tax_type
  belongs_to :store
  attr_accessible :cost, :description, :price, :quantity,
                  :work_order_id, :product_id, :tax_type_id, :store_id

  has_paper_trail

  validates :description,   :presence => true
  validates :work_order_id, :presence => true
  validates :product_id,    :presence => true
  validates :tax_type_id,   :presence => true
end
