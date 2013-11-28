class Area < ActiveRecord::Base
  belongs_to :department
  attr_accessible :name, :department_id

  has_paper_trail

  validates :name,          :presence => true
  validates :department_id, :presence => true
end
