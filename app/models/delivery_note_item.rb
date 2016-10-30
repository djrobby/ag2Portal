class DeliveryNoteItem < ActiveRecord::Base
  belongs_to :delivery_note
  belongs_to :sale_offer
  belongs_to :sale_offer_item
  belongs_to :product
  belongs_to :tax_type
  belongs_to :store
  belongs_to :work_order
  belongs_to :charge_account
  belongs_to :project
  attr_accessor :thing
  attr_accessible :cost, :description, :discount, :discount_pct, :price, :quantity,
                  :delivery_note_id, :sale_offer_id, :sale_offer_item_id, :product_id,
                  :tax_type_id, :store_id, :work_order_id, :charge_account_id, :project_id, :thing

  #has_many :client_invoice_items

  has_paper_trail

  #validates :delivery_note,   :presence => true
  validates :description,     :presence => true,
                              :length => { :maximum => 40 }
  validates :product,         :presence => true
  validates :tax_type,        :presence => true
  validates :store,           :presence => true
  #validates :work_order,      :presence => true
  validates :charge_account,  :presence => true
  validates :project,         :presence => true
  validates :quantity,        :numericality => true
  validates :price,           :numericality => true
  validates :cost,            :numericality => true
  validates :sale_offer_item, :presence => true, :if => "!sale_offer_id.blank?"

  #before_destroy :check_for_dependent_records
  before_validation :fields_to_uppercase
  after_create :update_stock_on_create
  after_update :update_stock_on_update
  after_destroy :update_stock_on_destroy
  # after_create :update_stock_on_create, :update_work_order_on_create
  # after_update :update_stock_on_update, :update_work_order_on_update
  # after_destroy :update_stock_on_destroy, :update_work_order_on_destroy

  def fields_to_uppercase
    if !self.description.blank?
      self[:description].upcase!
    end
    #true
    # Check current Stock
    check_stock(self.product, self.store, self.quantity)
  end

  #
  # Calculated fields
  #
  def costs
    quantity * cost
  end

  def amount
    quantity * (price - discount)
  end

  def tax
    (tax_type.tax / 100) * amount if !tax_type.nil?
  end

  def net
    amount - (amount * (delivery_note.discount_pct / 100)) if !delivery_note.discount_pct.blank?
  end

  def net_tax
    tax - (tax * (delivery_note.discount_pct / 100)) if !delivery_note.discount_pct.blank?
  end

  private

  # Before destroy
  def check_for_dependent_records
    # Check for client invoice items
    if client_invoice_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.delivery_note_item.check_for_client_invoices'))
      return false
    end
    true
  end

  #
  # Triggers to update linked models
  #
  #
  # After create
  #
  # Updates Stock (current)
  def update_stock_on_create
    # Update current Stock
    if !update_stock(product, store, quantity, true)
      return false
    end
    true
  end

  # Add new Item to linked Work Order Items
  def update_work_order_on_create
    _ok = true
    if !work_order.blank?
      _woi = WorkOrderItem.new(work_order_id: work_order_id, product_id: product_id, description: description, quantity: quantity, cost: cost,
                               price: price, tax_type_id: tax_type_id, store_id: store_id, created_by: delivery_note.created_by, charge_account_id: charge_account_id)
      if !_woi.save
        _ok = false
      end
    end
    _ok
  end

  #
  # After update
  #
  # Updates Stock (current and previous)
  def update_stock_on_update
    # What has changed?
    product_has_changed = product_changed? rescue false
    store_has_changed = store_changed? rescue false
    quantity_has_changed = quantity_changed? rescue false
    # Previous values
    product_prev = product_was rescue product
    store_prev = store_was rescue store
    quantity_prev = quantity_was rescue quantity
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
    true
  end

  # Update linked Work Order Item
  def update_work_order_on_update
    _ok = true
    _woi = WorkOrderItem.find_by_delivery_note_item_id(id)
    if !_woi.nil?
      if work_order.blank?
        _woi.destroy
      else
        _woi.attributes = { work_order_id: work_order_id, product_id: product_id, description: description, quantity: quantity, cost: cost,
                            price: price, tax_type_id: tax_type_id, store_id: store_id, charge_account_id: charge_account_id,
                            updated_by: delivery_note.updated_by.blank? ? delivery_note.created_by : delivery_note.updated_by }
        if !_woi.save
          _ok = false
        end
      end
    end
    _ok
  end

  #
  # After destroy
  #
  # Updates Stock (current)
  def update_stock_on_destroy
    # Update current Stock
    if !update_stock(product, store, quantity, false)
      return false
    end
    true
  end

  # Delete linked Work Order Item
  def update_work_order_on_destroy
    _ok = true
    _woi = WorkOrderItem.find_by_delivery_note_item_id(id)
    if !_woi.nil?
      _woi.destroy
    end
    _ok
  end

  #
  # Helper methods for triggers
  #
  # Update current Stock attributes: current
  # Warning: Only if product_type is different from 2!
  # Boolean is_new => true: current/new, false: previous/old
  def update_stock(_product, _store, _quantity, _is_new)
    if _product.product_type.id != 2
      _stock = Stock.find_by_product_and_store(_product, _store)
      if !_stock.nil?
        _stock.current = _is_new ? _stock.current - _quantity : _stock.current + _quantity
        if !_stock.save
          return false
        end
      end
    end
    true
  end

  # Delivery note item's quantity can't be greater than current stock
  # Warning: Only if product_type is different from 2!
  def check_stock(_product, _store, _quantity)
    _check_stock = true
    if _product.product_type.id != 2
      _stock = Stock.find_by_product_and_store(_product, _store)
      if !_stock.nil?
        if (_stock.current - _quantity) < 0
          errors.add(:description, I18n.t("activerecord.models.delivery_note_item.quantity_greater_than_stock_item", stock: _stock.current))
          _check_stock = false
        end
      end
    end
    _check_stock
  end
end
