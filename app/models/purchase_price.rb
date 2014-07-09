class PurchasePrice < ActiveRecord::Base
  belongs_to :product
  belongs_to :supplier
  belongs_to :measure
  attr_accessible :code, :factor, :favorite, :price, :product_id, :supplier_id, :measure_id,
                  :prev_code, :prev_price

  has_paper_trail

  validates :product,  :presence => true
  validates :supplier, :presence => true
  validates :measure,  :presence => true
  validates :code,     :presence => true

  after_save :update_reference_price_if_favorite

  def self.find_by_product_and_supplier(_product, _supplier)
    PurchasePrice.where("product_id = ? AND supplier_id = ?", _product, _supplier).first  
  end

  searchable do
    text :code
    integer :product_id
    integer :supplier_id
    integer :measure_id
    integer :id
    string :code
  end
  
  private
  
  # After save
  def update_reference_price_if_favorite
    if favorite
      product.reference_price = price
      if !product.save
        return false
      end      
    end
  end
end
