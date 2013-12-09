class OrderStatus < ActiveRecord::Base
  attr_accessible :approval, :name, :notification

  has_many :purchase_orders

  has_paper_trail

  validates :name,  :presence => true

  before_destroy :check_for_dependent_records

  private

  def check_for_dependent_records
    # Check for purchase orders
    if purchase_orders.count > 0
      errors.add(:base, I18n.t('activerecord.models.order_status.check_for_purchase_orders'))
      return false
    end
    # Check for sell orders
  end
end
