class WorkOrderItem < ActiveRecord::Base
  belongs_to :work_order
  belongs_to :product
  belongs_to :tax_type
  belongs_to :store
  belongs_to :charge_account
  belongs_to :delivery_note_item
  attr_accessor :thing
  attr_accessible :cost, :description, :price, :quantity,
                  :work_order_id, :product_id, :tax_type_id, :store_id, :thing,
                  :charge_account_id, :delivery_note_item_id,
                  :created_by, :updated_by

  has_paper_trail

  #validates :work_order,  :presence => true
  validates :description,     :presence => true
  validates :product,         :presence => true
  validates :tax_type,        :presence => true
  validates :charge_account,  :presence => true

  # Scopes
  scope :by_id, -> { order(:id) }
  #
  scope :belongs_to_work_order, -> work_order { where("work_order_id = ?", work_order).by_id }

  before_validation :fields_to_uppercase

  def fields_to_uppercase
    if !self.description.blank?
      self[:description].upcase!
    end
  end

  #
  # Calculated fields
  #
  def costs
    quantity * cost
  end

  def amount
    quantity * price
  end

  def tax
    (tax_type.tax / 100) * amount if !tax_type.nil?
  end
end
