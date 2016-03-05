class ProductCompanyPrice < ActiveRecord::Base
  belongs_to :product
  belongs_to :company
  belongs_to :supplier
  attr_accessible :average_price, :last_price, :product_id, :company_id, :prev_last_price,
                  :created_by, :updated_by, :supplier_id, :prev_supplier_id

  has_paper_trail

  #
  # Class (self) user defined methods
  #
  def self.find_by_product_and_company(_product, _company)
    ProductCompanyPrice.where("product_id = ? AND company_id = ?", _product, _company).first
  end

  searchable do
    integer :product_id
    integer :company_id
    integer :supplier_id
    integer :id
  end
end
