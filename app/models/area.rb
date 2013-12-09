class Area < ActiveRecord::Base
  belongs_to :department
  attr_accessible :name, :department_id

  has_many :work_orders

  has_paper_trail

  validates :name,        :presence => true
  validates :department,  :presence => true
   before_destroy :check_for_dependent_records

  private

  def check_for_dependent_records
    # Check for work orders
    if work_orders.count > 0
      errors.add(:base, I18n.t('activerecord.models.area.check_for_work_orders'))
      return false
    end
  end
end
