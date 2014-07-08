class ReceiptNoteItem < ActiveRecord::Base
  belongs_to :receipt_note
  belongs_to :purchase_order
  belongs_to :purchase_order_item
  belongs_to :product
  belongs_to :tax_type
  belongs_to :store
  belongs_to :work_order
  belongs_to :charge_account
  belongs_to :project
  attr_accessible :code, :description, :discount, :discount_pct, :price, :quantity,
                  :receipt_note_id, :purchase_order_id, :purchase_order_item_id,
                  :product_id, :tax_type_id, :store_id, :work_order_id,
                  :charge_account_id, :project_id

  has_many :supplier_invoice_items

  has_paper_trail

  validates :receipt_note,    :presence => true
  validates :description,     :presence => true,
                              :length => { :maximum => 40 }
  validates :product,         :presence => true
  validates :tax_type,        :presence => true
  validates :store,           :presence => true
  validates :work_order,      :presence => true
  validates :charge_account,  :presence => true
  validates :project,         :presence => true
  validates :quantity,        :numericality => true
  validates :price,           :numericality => true

  before_destroy :check_for_dependent_records
  before_validation :fields_to_uppercase
  before_save :check_for_new_stock_and_price
  after_create :update_stock_and_price_on_create
  after_update :update_stock_and_price_on_update

  def fields_to_uppercase
    if !self.description.blank?
      self[:description].upcase!
    end
    true
  end

  #
  # Calculated fields
  #
  def amount
    quantity * (price - discount)
  end

  def amount_was
    quantity_was * (price_was - discount_was)
  end

  def tax
    (tax_type.tax / 100) * amount if !tax_type.nil?
  end

  def net
    amount - (amount * (receipt_note.discount_pct / 100)) if !receipt_note.discount_pct.blank?
  end

  def net_tax
    tax - (tax * (receipt_note.discount_pct / 100)) if !receipt_note.discount_pct.blank?
  end

  private

  # Before destroy
  def check_for_dependent_records
    # Check for supplier invoice items
    if supplier_invoice_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.receipt_note_item.check_for_supplier_invoices'))
      return false
    end
  end
  
  #
  # Triggers to update linked models
  #
  # Before save (create & update)
  # Creates new Stock (unless product type 2) & PurchasePrice if don't exist
  def check_for_new_stock_and_price
    create_stock_if_necessary(product, store)
    create_purchase_price_if_necessary(product, receipt_note.supplier)
    true
  end
    
  # After create
  # Updates Stock & PurchasePrice (current)
  def update_stock_and_price_on_create
    # Update current Stock
    if !update_stock(product, store, quantity, true)
      return false
    end
    # Update current PurchasePrice
    if !update_purchase_price(product, receipt_note.supplier, price, code)
      return false
    end
    # Update current Product
    if !update_product(product, amount, quantity, price, true)
      return false
    end
    true
  end
  
  # After update
  # Updates Stock & PurchasePrice (current and previous)
  def update_stock_and_price_on_update
    #
    # Update current data if necessary
    #
    if product_changed? || store_changed? || quantity_changed?
      # Current Stock
      if !update_stock(product, store, quantity - quantity_was, true)
        return false
      end
    end
    if product_changed? || receipt_note.supplier_changed? || price_changed? || code_changed?
      # Current PurchasePrice
      if !update_purchase_price(product, receipt_note.supplier, price, code)
        return false
      end
    end
    if product_changed? || quantity_changed? || price_changed?
      # Current Product
      if !update_product(product, amount - amount_was, quantity - quantity_was, price, true)
        return false
      end
    end
    #
    # Roll back previous data if necessary
    #
    if product_changed? || store_changed?
      # Previous Stock
      if !update_stock(product_was, store_was, quantity_was, false)
        return false
      end
    end
    if product_changed? || receipt_note.supplier_changed?
      # Previous PurchasePrice
      if !update_purchase_price(product_was, receipt_note.supplier_was, price_was, code_was)
        return false
      end
    end 
    if product_changed?
      # Previous Product
      if !update_product(product_was, amount_was, quantity_was, price_was, false)
        return false
      end
    end
  end
  
  #
  # Helper methods for triggers
  #
  # Creates new Stock (unless product_type 2) if don't exist
  def create_stock_if_necessary(_product, _store)
    if _product.product_type.id != 2
      _stock = Stock.find_by_product_and_store(_product, _store)
      if _stock.nil?
        # Insert a new empty record if Stock doesn't exist
        _stock = Stock.create(product: _product, store: _store, initial: 0, current: 0, minimum: 0, maximum: 0, location: nil)
      end
    end
    true
  end

  # Creates new PurchasePrice if don't exist
  def create_purchase_price_if_necessary(_product, _supplier)
    _purchase_price = PurchasePrice.find_by_product_and_supplier(_product, _supplier)
    if _purchase_price.nil?
      # Insert a new empty record if PurchasePrice doesn't exist
      _purchase_price = PurchasePrice.create(product: _product, supplier: _supplier, code: nil, price: 0, measure: _product.measure, factor: 1)
    end
    true
  end

  # Update current Stock attributes: current
  # Warning: Only if product_type is different from 2!
  # Boolean is_new => true: current/new, false: previous/old
  def update_stock(_product, _store, _quantity, _is_new)
    if _product.product_type.id != 2
      _stock = Stock.find_by_product_and_store(_product, _store)
      if !_stock.nil?
        _stock.current = _is_new ? _stock.current + _quantity : _stock.current - _quantity
        if !_stock.save
          return false
        end
      end
    end
    true 
  end

  # Update current PurchasePrice attributes: price
  # Warning: If current PurchasePrice is favorite, Product reference_price will be updated automatically: Do not update it later!
  def update_purchase_price(_product, _supplier, _price, _code)
    _purchase_price = PurchasePrice.find_by_product_and_supplier(_product, _supplier)
    if _purchase_price.nil?
      _purchase_price.attributes = { price: _price, code: _code }
      if !_purchase_price.save
        return false
      end
    end
    true 
  end
  
  # Update current Product attributes: last_price, average_price
  # Boolean is_new => true: current/new, false: previous/old
  def update_product(_product, _amount, _quantity, _price, _is_new)
    _current_stock = _product.stock
    _current_average_price = _product.average_price
    if _is_new
      _new_average_price = ((_current_average_price * _current_stock) + _amount) / (_current_stock + _quantity)
    else
      _new_average_price = ((_current_average_price * _current_stock) - _amount) / (_current_stock - _quantity)
    end
    _product.attributes = { last_price: _price, average_price: _new_average_price }
    if !_product.save
      return false
    end
    true    
  end
end
