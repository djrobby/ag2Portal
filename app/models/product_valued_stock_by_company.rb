class ProductValuedStockByCompany < ActiveRecord::Base
  belongs_to :store
  belongs_to :product_family
  belongs_to :product
  belongs_to :company
  attr_accessible :store_id, :store_name, :product_family_id, :family_code, :family_name,
                  :product_id, :product_code, :main_description, :average_price,
                  :initial, :current, :current_value,
                  :company_id, :company_average_price, :company_current_value
end
