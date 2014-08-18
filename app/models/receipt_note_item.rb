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

  validates :receipt_note,        :presence => true
  validates :description,         :presence => true,
                                  :length => { :maximum => 40 }
  validates :product,             :presence => true
  validates :tax_type,            :presence => true
  validates :store,               :presence => true
  validates :work_order,          :presence => true
  validates :charge_account,      :presence => true
  validates :project,             :presence => true
  validates :quantity,            :numericality => true
  validates :price,               :numericality => true
  validates :purchase_order_item, :presence => true, :if => "!purchase_order_id.blank?"

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
    true
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
    if !update_purchase_price(product, receipt_note.supplier, price, code, 1)
      return false
    end
    # Update current Product
    if !update_product(product, amount, quantity, price, true, 1)
      return false
    end
    true
  end
  
  # After update
  # Updates Stock & PurchasePrice (current and previous)
  def update_stock_and_price_on_update
    # Stock
    if product_changed? || store_changed?
      # Current Stock
      if !update_stock(product, store, quantity, true)
        return false
      end
      # Roll back Previous Stock
      if !update_stock(product_was, store_was, quantity_was, false)
        return false
      end
    elsif quantity_changed?
      # Current Stock
      if !update_stock(product, store, quantity - quantity_was, true)
        return false
      end
    end
    # PurchasePrice
    if product_changed? || receipt_note.supplier_changed?
      # Current PurchasePrice
      if !update_purchase_price(product, receipt_note.supplier, price, code, 1)
        return false
      end
      # Roll back Previous PurchasePrice
      if !update_purchase_price(product_was, receipt_note.supplier_was, price, code, 2)
        return false
      end
    elsif price_changed? || code_changed?
      # Current PurchasePrice
      if !update_purchase_price(product, receipt_note.supplier, price, code, 0)
        return false
      end
    end
    # Product
    if product_changed?
      # Current Product
      if !update_product(product, amount, quantity, price, true, 1)
        return false
      end
      # Previous Product
      if !update_product(product_was, amount_was, quantity_was, price_was, false, 2)
        return false
      end
    elsif quantity_changed? || price_changed?
      # Current Product
      if !update_product(product, amount - amount_was, quantity - quantity_was, price, true, 0)
        return false
      end
    end
    true
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
      _purchase_price = PurchasePrice.create(product: _product, supplier: _supplier, code: nil, price: 0, measure: _product.measure, factor: 1, prev_code: nil, prev_price: 0)
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
  # Integer change_previous:  0 do nothing on previous values 
  #                           1 price & code => prev_price & prev_code (set previous values)
  #                           2 prev_price & prev_code => price & code (roll back values)
  def update_purchase_price(_product, _supplier, _price, _code, _change_previous)
    _purchase_price = PurchasePrice.find_by_product_and_supplier(_product, _supplier)
    if _purchase_price.nil?
      if _change_previous == 0
        _purchase_price.attributes = { price: _price, code: _code }
      elsif _change_previous == 1
        _purchase_price.attributes = { price: _price, code: _code, prev_price: _purchase_price.price, prev_code: _purchase_price.code }
      elsif _change_previous == 2
        _purchase_price.attributes = { price: _purchase_price.prev_price, code: _purchase_price.prev_code }
      end
      if !_purchase_price.save
        return false
      end
    end
    true 
  end
  
  # Update current Product attributes: last_price, average_price
  # Boolean is_new => true: current/new, false: previous/old
  # Integer change_previous:  0 do nothing on previous values 
  #                           1 last_price => prev_last_price (set previous value)
  #                           2 prev_last_price => last_price (roll back value)
  def update_product(_product, _amount, _quantity, _price, _is_new, _change_previous)
    _current_stock = _product.stock
    _current_average_price = _product.average_price
    # Weighted average price
    if _is_new
      _new_average_price = ((_current_average_price * _current_stock) + _amount) / (_current_stock + _quantity)
    else
      _new_average_price = ((_current_average_price * _current_stock) - _amount) / (_current_stock - _quantity)
    end
    _product.average_price = _new_average_price
    # Last price
    if _change_previous == 0
      _product.attributes = { last_price: _price }
    elsif _change_previous == 1
      _product.attributes = { last_price: _price, prev_last_price: _product.last_price }
    elsif _change_previous == 2
      _product.attributes = { last_price: _product.prev_last_price }
    end
    # Save changes
    if !_product.save
      return false
    end
    true    
  end
end
