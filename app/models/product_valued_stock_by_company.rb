class ProductValuedStockByCompany < ActiveRecord::Base
  belongs_to :store
  belongs_to :product_family
  belongs_to :product
  belongs_to :company
  attr_accessible :store_id, :store_name, :product_family_id, :family_code, :family_name,
                  :product_id, :product_code, :main_description, :average_price,
                  :initial, :current, :current_value,
                  :company_id, :company_average_price, :company_current_value
  # Scopes
  scope :ordered_by_store_family, -> { order(:store_id, :product_family_id) }
  #
  scope :belongs_to_company, -> company { where("company_id = ? OR company_id IS NULL", company) }
  #
  scope :belongs_to_company_store, -> company, family { belongs_to_company(company).where("store_id = ?", store) }
  scope :belongs_to_company_family, -> company, family { belongs_to_company(company).where("product_family_id = ?", family) }
  scope :belongs_to_company_product, -> company, product { belongs_to_company(company).where("product_id = ?", product) }
  #
  scope :belongs_to_company_store_family, -> company, store, family { belongs_to_company(company).belongs_to_store(store).where("product_family_id = ?", family) }
  scope :belongs_to_company_store_product, -> company, store, product { belongs_to_company(company).belongs_to_store(store).where("product_id = ?", product) }
  scope :belongs_to_company_family_product, -> company, family, product { belongs_to_company(company).belongs_to_family(family).where("product_id = ?", product) }
end
