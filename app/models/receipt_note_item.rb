class ReceiptNoteItem < ActiveRecord::Base
  include ModelsModule

  belongs_to :receipt_note
  belongs_to :purchase_order
  belongs_to :purchase_order_item
  belongs_to :product
  belongs_to :tax_type
  belongs_to :store
  belongs_to :work_order
  belongs_to :charge_account
  belongs_to :project
  attr_accessor :thing
  attr_accessible :code, :description, :discount, :discount_pct, :price, :quantity,
                  :receipt_note_id, :purchase_order_id, :purchase_order_item_id,
                  :product_id, :tax_type_id, :store_id, :work_order_id,
                  :charge_account_id, :project_id, :thing

  has_many :supplier_invoice_items
  has_one :receipt_note_item_balance

  has_paper_trail

  #validates :receipt_note,        :presence => true
  validates :description,         :presence => true,
                                  :length => { :maximum => 40 }
  validates :product,             :presence => true
  validates :tax_type,            :presence => true
  validates :store,               :presence => true
  #validates :work_order,          :presence => true
  #validates :charge_account,      :presence => true
  validates :project,             :presence => true
  validates :quantity,            :numericality => true
  validates :price,               :numericality => true
  validates :purchase_order_item, :presence => true, :if => "!purchase_order_id.blank?"

  # Callbacks
  before_destroy :check_for_dependent_records
  before_validation :fields_to_uppercase
  before_save :check_for_new_stock_and_price
  after_create :update_stock_and_price_on_create
  after_update :update_stock_and_price_on_update
  after_destroy :update_stock_and_price_on_destroy

  def to_label
    "#{full_item}"
  end

  def full_item
    full_item = self.id.to_s + ": " + self.product.full_code + " " + self.description[0,20]
    full_item += " " + (!self.quantity.blank? ? formatted_number(self.quantity, 4) : formatted_number(0, 4))
    full_item += " " + (!self.net_price.blank? ? formatted_number(self.net_price, 4) : formatted_number(0, 4))
    full_item += " " + (!self.amount.blank? ? formatted_number(self.amount, 4) : formatted_number(0, 4))
    full_item += " (" + (!self.balance.blank? ? formatted_number(self.balance, 4) : formatted_number(0, 4)) + ")"
  end

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
    quantity * net_price
  end

  def amount_was
    quantity_prev = quantity_was rescue quantity
    price_prev = price_was rescue price
    discount_prev = discount_was rescue discount
    quantity_prev * (price_prev - discount_prev)
  end

  def tax
    (tax_type.tax / 100) * amount if !tax_type.nil?
  end

  def net
    if receipt_note && !receipt_note.discount_pct.blank?
      amount - (amount * (receipt_note.discount_pct / 100))
    else
      amount
    end
  end

  def net_tax
    if receipt_note && !receipt_note.discount_pct.blank?
      tax - (tax * (receipt_note.discount_pct / 100))
    else
      tax
    end
  end

  def net_price
    price - discount
  end

  def balance
    receipt_note_item_balance.balance
    #quantity - supplier_invoice_items.sum("quantity")
  end

  # The item is meter?
  def is_meter
    product.product_family.is_meter || false
  end

  #
  # Class (self) user defined methods
  #
  def self.bill_total #billing_status = Total --> 0
    includes(:receipt_note).joins(:receipt_note_item_balance).group('receipt_notes.id').having('sum(receipt_note_item_balances.balance) <= ?', 0)
  end

  def self.bill_partial #billing_status = Parcial --> 1
    includes(:receipt_note).joins(:receipt_note_item_balance).group('receipt_notes.id').having('sum(receipt_note_item_balances.balance) != sum(receipt_note_items.quantity) AND sum(receipt_note_item_balances.balance) > ? ', 0)
  end

  def self.bill_unbilled #billing_status = No facturado --> 2
    includes(:receipt_note).joins(:receipt_note_item_balance).group('receipt_notes.id').having('sum(receipt_note_item_balances.balance) = sum(receipt_note_items.quantity) AND sum(receipt_note_item_balances.balance) > ? ', 0)
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
    self.created_by = receipt_note.created_by
    self.updated_by = receipt_note.updated_by

    create_stock_if_necessary(product, store)
    create_purchase_price_if_necessary(product, receipt_note.supplier)
    true
  end

  # After create
  # Updates Stock & PurchasePrice (current)
  # Current stock must be update last! (WAP)
  def update_stock_and_price_on_create
    # Update current PurchasePrice
    if !update_purchase_price(product, receipt_note.supplier, price, code, 1, discount_pct)
      return false
    end
    # Update current Product
    if !update_product(product, amount, quantity, net_price, true, 1)
      return false
    end
    # Update current ProductCompanyPrice
    if !update_product_company_price(product, store.company, amount, quantity, net_price, true, 1, receipt_note.supplier)
      return false
    end
    # Update current Stock
    if !update_stock(product, store, quantity, true)
      return false
    end
    # Everything run smoothly
    true
  end

  # After update
  # Updates Stock & PurchasePrice (current and previous)
  def update_stock_and_price_on_update
    # What has changed?
    product_has_changed = product_changed? rescue false
    store_has_changed = store_changed? rescue false
    quantity_has_changed = quantity_changed? rescue false
    supplier_has_changed = receipt_note.supplier_changed? rescue false
    price_has_changed = price_changed? rescue false
    code_has_changed = code_changed? rescue false
    discount_pct_has_changed = discount_pct_changed? rescue false
    discount_has_changed = discount_changed? rescue false
    # Previous values
    product_prev = product_was rescue product
    store_prev = store_was rescue store
    quantity_prev = quantity_was rescue quantity
    supplier_prev = receipt_note.supplier_was rescue receipt_note.supplier
    amount_prev = amount_was rescue amount
    price_prev = price_was rescue price
    discount_pct_prev = discount_pct_was rescue discount_pct
    discount_prev = discount_was rescue discount
    net_price_prev = price_prev - discount_prev
    # PurchasePrice
    if product_has_changed || supplier_has_changed
      # Current PurchasePrice
      if !update_purchase_price(product, receipt_note.supplier, price, code, 1, discount_pct)
        return false
      end
      # Roll back Previous PurchasePrice
      if !update_purchase_price(product_prev, supplier_prev, price, code, 2, discount_pct)
        return false
      end
    elsif price_has_changed || code_has_changed || discount_pct_has_changed
      # Current PurchasePrice
      if !update_purchase_price(product, receipt_note.supplier, price, code, 0, discount_pct)
        return false
      end
    end
    # Product
    if product_has_changed
      # Current Product
      if !update_product(product, amount, quantity, net_price, true, 1)
        return false
      end
      # Previous Product
      if !update_product(product_prev, amount_prev, quantity_prev, net_price_prev, false, 2)
        return false
      end
    elsif quantity_has_changed || price_has_changed || discount_has_changed
      # Current Product
      if !update_product(product, amount - amount_prev, quantity - quantity_prev, net_price, true, 0)
        return false
      end
    end
    # ProductCompanyPrice
    if product_has_changed || store_has_changed || supplier_has_changed
      # Current ProductCompanyPrice
      if !update_product_company_price(product, store.company, amount, quantity, net_price, true, 1, receipt_note.supplier)
        return false
      end
      # Previous ProductCompanyPrice
      if !update_product_company_price(product_prev, store_prev.company, amount_prev, quantity_prev, net_price_prev, false, 2, supplier_prev)
        return false
      end
    elsif quantity_has_changed || price_has_changed || discount_has_changed
      # Current ProductCompanyPrice
      if !update_product_company_price(product, store.company, amount - amount_prev, quantity - quantity_prev, net_price, true, 0, receipt_note.supplier)
        return false
      end
    end
    # Stock
    if product_has_changed || store_has_changed
      # Current Stock
      if !update_stock(product, store, quantity, true)
        return false
      end
      # Roll back Previous Stock
      if !update_stock(product_prev, store_prev, quantity_prev, false)
        return false
      end
    elsif quantity_has_changed
      # Current Stock
      if !update_stock(product, store, quantity - quantity_prev, true)
        return false
      end
    end
    # Everything run smoothly
    true
  end

  # After destroy
  # Updates Stock & PurchasePrice (current)
  # Current stock must be update last! (WAP)
  def update_stock_and_price_on_destroy
    # Update current PurchasePrice
    if !update_purchase_price(product, receipt_note.supplier, price, code, 2, discount_pct)
      return false
    end
    # Update current Product
    if !update_product(product, amount, quantity, net_price, false, 2)
      return false
    end
    # Update current ProductCompanyPrice
    if !update_product_company_price(product, store.company, amount, quantity, net_price, false, 2, receipt_note.supplier)
      return false
    end
    # Update current Stock
    if !update_stock(product, store, quantity, false)
      return false
    end
    # Everything run smoothly
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
        #_stock = Stock.create(product_id: _product.id, store_id: _store.id, initial: 0, current: 0, minimum: 0, maximum: 0, location: nil, created_by: current_user.nil? ? nil : current_user.id)
        _stock = Stock.create(product_id: _product.id, store_id: _store.id, initial: 0, current: 0, minimum: 0, maximum: 0, location: nil, created_by: receipt_note.created_by)
      end
    end
    true
  end

  # Creates new PurchasePrice if don't exist
  def create_purchase_price_if_necessary(_product, _supplier)
    _purchase_price = PurchasePrice.find_by_product_and_supplier(_product, _supplier)
    if _purchase_price.nil?
      # Insert a new empty record if PurchasePrice doesn't exist
      #_purchase_price = PurchasePrice.create(product_id: _product.id, supplier_id: _supplier.id, code: nil, price: 0, measure_id: _product.measure.id, factor: 1, prev_code: nil, prev_price: 0, created_by: current_user.nil? ? nil : current_user.id)
      _purchase_price = PurchasePrice.create(product_id: _product.id, supplier_id: _supplier.id, code: nil, price: 0, measure_id: _product.measure.id, factor: 1, prev_code: nil, prev_price: 0, created_by: receipt_note.created_by)
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
        # Updater
        #_stock.updated_by = current_user.id if !current_user.nil?
        _stock.updated_by = receipt_note.updated_by.blank? ? receipt_note.created_by : receipt_note.updated_by
        # Save changes
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
  def update_purchase_price(_product, _supplier, _price, _code, _change_previous, _discount_pct)
    _purchase_price = PurchasePrice.find_by_product_and_supplier(_product, _supplier)
    if !_purchase_price.nil?
      if _change_previous == 0
        _purchase_price.attributes = { price: _price, code: _code, discount_rate: _discount_pct }
      elsif _change_previous == 1
        _purchase_price.attributes = { price: _price, code: _code, discount_rate: _discount_pct,
                                       prev_price: _purchase_price.price, prev_code: _purchase_price.code, prev_discount_rate: _purchase_price.discount_rate }
      elsif _change_previous == 2
        _purchase_price.attributes = { price: _purchase_price.prev_price, code: _purchase_price.prev_code, discount_rate: _purchase_price.prev_discount_rate }
      end
      # Updater
      #_purchase_price.updated_by = current_user.id if !current_user.nil?
      _purchase_price.updated_by = receipt_note.updated_by.blank? ? receipt_note.created_by : receipt_note.updated_by
      # Save changes
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
    _new_average_price = 0
    if _is_new
      # _new_average_price = ((_current_average_price * _current_stock) + _amount) / (_current_stock + _quantity)
      _new_average_price = (_current_stock + _quantity) != 0 ?
                           ((_current_average_price * _current_stock) + _amount) / (_current_stock + _quantity) : _current_average_price
    else
      # _new_average_price = ((_current_average_price * _current_stock) - _amount) / (_current_stock - _quantity)
      _new_average_price = (_current_stock - _quantity) != 0 ?
                           ((_current_average_price * _current_stock) - _amount) / (_current_stock - _quantity) : 0
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
    # Updater
    #_product.updated_by = current_user.id if !current_user.nil?
    _product.updated_by = receipt_note.updated_by.blank? ? receipt_note.created_by : receipt_note.updated_by
    # Save changes
    if !_product.save
      return false
    end
    true
  end

  # Update current ProductCompanyPrice attributes: last_price, average_price
  # Boolean is_new => true: current/new, false: previous/old
  # Integer change_previous:  0 do nothing on previous values
  #                           1 last_price => prev_last_price (set previous value)
  #                           2 prev_last_price => last_price (roll back value)
  def update_product_company_price(_product, _company, _amount, _quantity, _price, _is_new, _change_previous, _supplier)
    # Do nothing if company is empty (can go on normally)
    if _company.blank?
      return true
    end
    # Calc current stock by company
    _current_stock = 0
    _stores = _company.stores
    _stores.each do |_s|
      _current_stock += Stock.find_by_product_and_store(_product, _s).current rescue 0
      #_current_stock += s.stock
    end
    # Current company weighted average price
    _current_average_price = 0
    _product_company_price = ProductCompanyPrice.find_by_product_and_company(_product, _company) rescue nil
    if _product_company_price.nil?
      #_product_company_price = ProductCompanyPrice.create(product_id: _product.id, company_id: _company.id, last_price: 0, average_price: 0, prev_last_price: 0, created_by: current_user.nil? ? nil : current_user.id, supplier_id: _supplier.id)
      _product_company_price = ProductCompanyPrice.create(product_id: _product.id, company_id: _company.id, last_price: 0, average_price: 0, prev_last_price: 0, created_by: receipt_note.created_by, supplier_id: _supplier.id)
    else
      _current_average_price = _product_company_price.average_price
    end
    # Calc new Weighted average price
    _new_average_price = 0
    if _is_new
      _new_average_price = (_current_stock + _quantity) != 0 ?
                           ((_current_average_price * _current_stock) + _amount) / (_current_stock + _quantity) : _current_average_price
    else
      _new_average_price = (_current_stock - _quantity) != 0 ?
                           ((_current_average_price * _current_stock) - _amount) / (_current_stock - _quantity) : 0
    end
    _product_company_price.average_price = _new_average_price
    # Last price
    if _change_previous == 0
      _product_company_price.attributes = { last_price: _price, supplier_id: _supplier.id }
    elsif _change_previous == 1
      _product_company_price.attributes = { last_price: _price, prev_last_price: _product_company_price.last_price, supplier_id: _supplier.id, prev_supplier_id: _product_company_price.supplier_id }
    elsif _change_previous == 2
      _product_company_price.attributes = { last_price: _product_company_price.prev_last_price, supplier_id: _product_company_price.prev_supplier_id }
    end
    # Updater
    #_product_company_price.updated_by = current_user.id if !current_user.nil?
    _product_company_price.updated_by = receipt_note.updated_by.blank? ? receipt_note.created_by : receipt_note.updated_by
    # Save changes
    if !_product_company_price.save
      return false
    end
    true
  end
end
