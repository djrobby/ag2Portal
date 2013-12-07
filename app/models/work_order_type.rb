class WorkOrderType < ActiveRecord::Base
  attr_accessible :name

  has_many :work_orders

  has_paper_trail

  validates :name,  :presence => true
end
