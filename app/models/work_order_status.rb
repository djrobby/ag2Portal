class WorkOrderStatus < ActiveRecord::Base
  # CONSTANTS
  NOSTARTED = 1
  STARTED = 2
  COMPLETED = 3
  CLOSED = 4

  attr_accessible :name

  has_many :work_orders

  has_paper_trail

  validates :name,  :presence => true

  before_destroy :check_for_dependent_records

  def code
    case self.id
    when 1 then I18n.t('activerecord.attributes.work_order_status.code_1')
    when 2 then I18n.t('activerecord.attributes.work_order_status.code_2')
    when 3 then I18n.t('activerecord.attributes.work_order_status.code_3')
    when 4 then I18n.t('activerecord.attributes.work_order_status.code_4')
    else name[0,3].delete(' ').upcase
    end
  end

  private

  def check_for_dependent_records
    # Check for work orders
    if work_orders.count > 0
      errors.add(:base, I18n.t('activerecord.models.work_order_status.check_for_work_orders'))
      return false
    end
  end
end
