class WorkerSalary < ActiveRecord::Base
  belongs_to :worker_item
  attr_accessible :day_pct, :gross_salary, :social_security_cost, :variable_salary, :year,
                  :active, :worker_item_id, :overtime

  has_many :worker_salary_items, dependent: :destroy

  has_paper_trail

  validates :worker_item, :presence => true
  validates :year,        :presence => true

  def to_label
    "#{id} - #{year} - #{worker_item.worker.full_name}"
  end

  def total_cost
    gross_salary + variable_salary + social_security_cost
  end

  def items_sum
    worker_salary_items.sum("amount")
  end
end
