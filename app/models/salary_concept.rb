class SalaryConcept < ActiveRecord::Base
  attr_accessible :name

  has_many :worker_salary_items

  validates :name,  :presence => true

  has_paper_trail
end
