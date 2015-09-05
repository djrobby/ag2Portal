class ProductFamilyStock < ActiveRecord::Base
  belongs_to :product_family
  attr_accessible :product_family_id, :family_code, :family_name, :store_id, :store_name, :initial, :current
end
