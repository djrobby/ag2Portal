class ProductValuedStock < ActiveRecord::Base
  belongs_to :store
  belongs_to :product_family
  belongs_to :product
  attr_accessible :store_id, :store_name, :product_family_id, :family_code, :family_name,
                  :product_id, :product_code, :main_description, :average_price,
                  :initial, :current, :current_value
end
