class PurchaseOrderItem < ActiveRecord::Base
  include ModelsModule

  belongs_to :purchase_order
  belongs_to :product
  belongs_to :tax_type
  belongs_to :project
  belongs_to :store
  belongs_to :work_order
  belongs_to :charge_account
  attr_accessor :thing
  attr_accessible :code, :delivery_date, :description, :discount, :discount_pct, :quantity, :price,
                  :purchase_order_id, :product_id, :tax_type_id, :project_id,
                  :store_id, :work_order_id, :charge_account_id, :thing

  has_many :receipt_note_items
  has_one :purchase_order_item_balance
  has_one :purchase_order_item_invoiced_balance

  has_paper_trail

  #validates :purchase_order,  :presence => true
  validates :description,     :presence => true,
                              :length => { :maximum => 40 }
  validates :product,         :presence => true
  validates :quantity,        :numericality => true
  validates :price,           :numericality => true
  validates :tax_type,        :presence => true
  validates :project,         :presence => true
  validates :store,           :presence => true
  #validates :work_order,      :presence => true
  validates :charge_account,  :presence => true

  # Callbacks
  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records

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
  end

  #
  # Calculated fields
  #
  def amount
    quantity * net_price
  end

  def tax
    (tax_type.tax / 100) * amount if !tax_type.nil?
  end

  def net
    if purchase_order && !purchase_order.discount_pct.blank?
      amount - (amount * (purchase_order.discount_pct / 100))
    else
      amount
    end
  end

  def net_tax
    if purchase_order && !purchase_order.discount_pct.blank?
      tax - (tax * (purchase_order.discount_pct / 100))
    else
      tax
    end
  end

  def net_price
    price - discount
  end

  def balance
    purchase_order_item_balance.balance
    #quantity - purchase_order_items.sum("quantity")
  end

  def unbilled_balance
    purchase_order_item_invoiced_balance.balance
  end

  def delay
    d = 0
    if balance > 0
      d = (Time.now.to_date - purchase_order.order_date).to_i
    end
    d
  end

  private

  def check_for_dependent_records
    # Check for receipt note items
    if receipt_note_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.purchase_order_item.check_for_receipt_notes'))
      return false
    end
  end
end
