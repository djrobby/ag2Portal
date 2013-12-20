class WorkerSalary < ActiveRecord::Base
  belongs_to :worker_item
  attr_accessible :day_pct, :gross_salary, :social_security_cost, :variable_salary, :year,
                  :active, :worker_item_id

  has_many :worker_salary_items

  has_paper_trail

  validates :worker_item, :presence => true
  validates :year,        :presence => true

  def total_cost
    gross_salary + variable_salary + social_security_cost
  end
end
