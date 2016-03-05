class PurchasePrice < ActiveRecord::Base
  belongs_to :product
  belongs_to :supplier
  belongs_to :measure
  attr_accessible :code, :factor, :favorite, :price, :product_id, :supplier_id, :measure_id,
                  :prev_code, :prev_price, :discount_rate, :prev_discount_rate,
                  :created_by, :updated_by

  has_paper_trail

  validates :product,  :presence => true
  validates :supplier, :presence => true
  validates :measure,  :presence => true
  #validates :code,     :presence => true

  after_save :update_reference_price_if_favorite

  def self.find_by_product_and_supplier(_product, _supplier)
    PurchasePrice.where("product_id = ? AND supplier_id = ?", _product, _supplier).first
  end

  def self.find_product_best_price(_product)
    PurchasePrice.where("product_id = ?", _product).order("(price - (price * (discount_rate / 100)))").first
  end

  def discount
    price * (discount_rate / 100)
  end

  def net_price
    price - discount
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
    _ret = true
    if favorite
      #product.reference_price = price - (price * (discount_rate / 100))
      product.reference_price = price
      if !product.save
        _ret = false
      end
    end
    _ret
  end
end
