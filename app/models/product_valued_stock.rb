class ProductValuedStock < ActiveRecord::Base
  belongs_to :store
  belongs_to :product_family
  belongs_to :product
  attr_accessible :store_id, :store_name, :product_family_id, :family_code, :family_name,
                  :product_id, :product_code, :main_description, :average_price,
                  :initial, :current, :current_value
  # Scopes
  scope :ordered_by_store_family, -> { order(:store_id, :family_code, :product_code) }
  #
  scope :belongs_to_store, -> store { where("store_id = ?", store).ordered_by_store_family }
  scope :belongs_to_family, -> family { where("product_family_id = ?", family).ordered_by_store_family }
  scope :belongs_to_product, -> product { where("product_id = ?", product).ordered_by_store_family }
  #
  scope :belongs_to_store_family, -> store, family { belongs_to_store(store).where("product_family_id = ?", family).ordered_by_store_family }
  scope :belongs_to_store_product, -> store, product { belongs_to_store(store).where("product_id = ?", product).ordered_by_store_family }
  #
  #scope :belongs_to_store_family_product, -> store, family, product { belongs_to_store(store).belongs_to_family(family).where("product_id = ?", product) }
end
