class InventoryCountItem < ActiveRecord::Base
  belongs_to :inventory_count
  belongs_to :product
  attr_accessor :thing
  attr_accessible :quantity, :inventory_count_id, :product_id, :initial, :current, :thing,
                  :price, :average_price

  has_paper_trail

  validates :product,   :presence => true
  validates :quantity,  :numericality => { :greater_than_or_equal_to => 0}

  def stocks
    product.stocks
  end

  #
  # Calculated fields
  #
  def initial_stock_by_store
    _store = inventory_count.store_id rescue 0
    stocks.where("store_id = ?", _store).sum("initial")
  end

  def current_stock_by_store
    _store = inventory_count.store_id rescue 0
    stocks.where("store_id = ?", _store).sum("current")
  end

  def amount
    quantity * price
  end
end
