class ProductCompanyPrice < ActiveRecord::Base
  belongs_to :product
  belongs_to :company
  attr_accessible :average_price, :last_price, :product_id, :company_id

  has_paper_trail
end
