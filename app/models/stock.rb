class Stock < ActiveRecord::Base
  belongs_to :product
  belongs_to :store
  attr_accessible :current, :initial, :location, :minimum, :maximum, :product_id, :store_id

  has_paper_trail

  validates :product,  :presence => true
  validates :store,    :presence => true

  def self.find_by_product_and_store(_product, _store)
    Stock.where("product_id = ? AND store_id = ?", _product, _store).first 
  end

  def self.find_by_product_and_not_store_and_positive(_product, _store)
    Stock.includes(:store).where("product_id = ? AND store_id != ? AND current > 0 AND stores.supplier_id IS NULL", _product, _store) 
  end

  def self.find_by_product_all_stocks(_product)
    Stock.includes(:store).where("product_id = ?", _product) 
  end
  
  searchable do
    integer :product_id
    integer :store_id
    integer :id
  end
end
