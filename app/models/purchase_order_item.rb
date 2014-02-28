class PurchaseOrderItem < ActiveRecord::Base
  belongs_to :purchase_order
  belongs_to :product
  belongs_to :tax_type
  belongs_to :project
  belongs_to :store
  belongs_to :work_order
  belongs_to :charge_account
  attr_accessible :code, :delivery_date, :description, :discount, :discount_pct, :quantity, :price,
                  :purchase_order_id, :product_id, :tax_type_id, :project_id,
                  :store_id, :work_order_id, :charge_account_id

  has_many :receipt_note_items

  has_paper_trail

  validates :purchase_order,  :presence => true
  validates :description,     :presence => true,
                              :length => { :maximum => 40 }
  validates :product,         :presence => true
  validates :tax_type,        :presence => true
  validates :project,         :presence => true
  validates :store,           :presence => true
  validates :work_order,      :presence => true
  validates :charge_account,  :presence => true

  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records

  def fields_to_uppercase
    if !self.description.blank?
      self[:description].upcase!
    end
  end

  #
  # Calculated fields
  #
  def amount
    quantity * (price - discount)
  end

  def tax
    tax_type.tax * amount
  end
  
  def balance
    quantity - receipt_note_items.sum("quantity")
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
