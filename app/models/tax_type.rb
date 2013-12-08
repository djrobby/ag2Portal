class TaxType < ActiveRecord::Base
  attr_accessible :description, :tax, :expiration,
                  :created_by, :updated_by

  has_many :products
  has_many :work_order_items
  has_many :purchase_order_items
  has_many :receipt_note_items

  has_paper_trail

  validates :description, :presence => true
  validates :tax,         :presence => true

  before_destroy :check_for_dependent_records

  def to_label
    "#{description} (#{tax})"
  end

  private
  
  def check_for_dependent_records
    # Check for products
    if products.count > 0
      errors.add(:base, I18n.t('activerecord.models.tax_type.check_for_products'))
      return false
    end
  # Check for orders & ...
  #    if orders.count > 0
  #      errors.add(:base, I18n.t('activerecord.models.product.check_for_orders'))
  #      return false
  #    end
  end
end
