class InventoryTransferItem < ActiveRecord::Base
  belongs_to :inventory_transfer
  belongs_to :product
  attr_accessor :thing
  attr_accessible :average_price, :inbound_current, :outbound_current, :price, :quantity, :thing,
                  :inventory_transfer_id, :product_id

  has_paper_trail

  validates :product,   :presence => true
  validates :quantity,  :numericality => { :greater_than => 0}

  def stocks
    product.stocks
  end

  #
  # Calculated fields
  #
  def current_stock_by_outbound_store
    _store = inventory_transfer.outbound_store_id rescue 0
    stocks.where("store_id = ?", _store).sum("current")
  end

  def current_stock_by_inbound_store
    _store = inventory_transfer.inbound_store_id rescue 0
    stocks.where("store_id = ?", _store).sum("current")
  end

  def amount
    quantity * price
  end
end
