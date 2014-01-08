class WorkerSalaryItem < ActiveRecord::Base
  belongs_to :worker_salary
  belongs_to :salary_concept
  attr_accessible :amount, :worker_salary_id, :salary_concept_id

  has_paper_trail

  validates :worker_salary,   :presence => true
  validates :salary_concept,  :presence => true
end
