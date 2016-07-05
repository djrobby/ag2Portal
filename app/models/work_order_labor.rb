class WorkOrderLabor < ActiveRecord::Base
  belongs_to :organization
  belongs_to :work_order_type
  attr_accessible :name, :organization_id, :work_order_type_id

  has_many :work_orders

  has_paper_trail

  validates :name,  :presence => true
  validates :organization,    :presence => true

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
