class Stock < ActiveRecord::Base
  belongs_to :product
  belongs_to :store
  attr_accessible :current, :initial, :location, :minimum, :maximum, :product_id, :store_id,
                  :created_by, :updated_by

  has_paper_trail

  validates :product,   :presence => true
                        # :uniqueness => { :scope => :store_id }
  validates :store,     :presence => true

  # Receipts
  def receipt_note_items
    ReceiptNoteItem.where(product_id: self.product, store_id: self.store)
  end
  def receipts
    receipt_note_items.sum("quantity")
    #ReceiptNoteItem.where(product_id: self.product, store_id: self.store).sum("quantity")
  end
  def receipts_price_avg
    receipt_note_items.sum("price") / receipt_note_items.count
  end
  def receipts_discount
    receipt_note_items.sum("discount")
  end
  def receipts_amount
    _sum = 0
    receipt_note_items.each do |i|
      if !i.amount.blank?
        _sum += i.amount
      end
    end
    _sum
  end

  # Deliveries
  def delivery_note_items
    DeliveryNoteItem.where(product_id: self.product, store_id: self.store)
  end
  def deliveries
    delivery_note_items.sum("quantity")
    #DeliveryNoteItem.where(product_id: self.product, store_id: self.store).sum("quantity")
  end
  def deliveries_price_avg
    delivery_note_items.sum("price") / delivery_note_items.count
  end
  def deliveries_discount
    delivery_note_items.sum("discount")
  end
  def deliveries_amount
    _sum = 0
    delivery_note_items.each do |i|
      if !i.amount.blank?
        _sum += i.amount
      end
    end
    _sum
  end

  # Stock rotation rate
  # Delivery notes valued at cost (deliveries_costs) divided by WAP (average_price)
  def rotation_rate
    if (initial + current) == 0
      0
    else
      deliveries / ((initial + current) / 2)
    end
  end

  #
  # Class (self) user defined methods
  #
  def self.find_by_product_and_store(_product, _store)
    Stock.where("product_id = ? AND store_id = ?", _product, _store).first
  end

  def self.find_by_product_and_not_store_and_positive(_product, _store)
    Stock.includes(:store).where("product_id = ? AND store_id != ? AND current > 0 AND stores.supplier_id IS NULL", _product, _store)
  end

  def self.find_by_product_all_stocks(_product)
    Stock.includes(:store).where("product_id = ?", _product)
  end

  def self.find_by_store_and_family(_store, _family)
    joins(:product).where("store_id = ? AND products.product_family_id = ?", _store, _family)
  end

  def self.find_by_product_and_company(_product, _company)
    joins(:store).where("product_id = ? AND stores.company_id = ?", _product, _company)
  end

  searchable do
    integer :product_id
    integer :store_id
    integer :id
  end
end
