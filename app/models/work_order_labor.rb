class WorkOrderLabor < ActiveRecord::Base
  attr_accessible :name

  has_many :work_orders
  
  has_paper_trail

  validates :name,  :presence => true

  before_destroy :check_for_dependent_records

  private

  def check_for_dependent_records
    # Check for work orders
    if work_orders.count > 0
      errors.add(:base, I18n.t('activerecord.models.work_order_labor.check_for_work_orders'))
      return false
    end
  end
end
