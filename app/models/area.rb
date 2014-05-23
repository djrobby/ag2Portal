class Area < ActiveRecord::Base
  belongs_to :department
  belongs_to :worker
  attr_accessible :name, :department_id, :worker_id

  has_many :work_orders

  has_paper_trail

  validates :name,        :presence => true
  validates :department,  :presence => true
  
  before_destroy :check_for_dependent_records

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = ""
    if !self.name.blank?
      full_name += self.name
    end
    if !self.department.blank?
      full_name += " (" + self.department.name + ")"
    end
    full_name
  end

  private

  def check_for_dependent_records
    # Check for work orders
    if work_orders.count > 0
      errors.add(:base, I18n.t('activerecord.models.area.check_for_work_orders'))
      return false
    end
  end
end
