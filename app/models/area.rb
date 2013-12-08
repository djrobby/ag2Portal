class Area < ActiveRecord::Base
  belongs_to :department
  attr_accessible :name, :department_id

  has_many :work_orders

  has_paper_trail

  validates :name,        :presence => true
  validates :department,  :presence => true
end
