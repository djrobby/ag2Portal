class Product < ActiveRecord::Base
  belongs_to :product_type
  belongs_to :product_family
  belongs_to :measure
  belongs_to :tax_type
  belongs_to :manufacturer
  attr_accessible :active, :aux_code, :aux_description, :average_price, :last_price, :life_time, :main_description, :manufacturer_p_code, :markup, :product_code, :reference_price, :remarks, :sell_price, :warranty_time
end
