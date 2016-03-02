class ProductCompanyPrice < ActiveRecord::Base
  belongs_to :product
  belongs_to :company
  attr_accessible :average_price, :last_price, :product_id, :company_id, :prev_last_price,
                  :created_by, :updated_by

  has_paper_trail

  #
  # Class (self) user defined methods
  #
  def self.find_by_product_and_company(_product, _company)
    ProductCompanyPrice.where("product_id = ? AND company_id = ?", _product, _company).first
  end
end
