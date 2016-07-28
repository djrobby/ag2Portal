class WorkOrderTypeAccount < ActiveRecord::Base
  belongs_to :work_order_type
  belongs_to :project
  belongs_to :charge_account
  attr_accessor :thing_project, :thing_account
  attr_accessible :work_order_type_id, :project_id, :charge_account_id, :thing_project, :thing_account

  has_paper_trail

  #validates :work_order_type, :presence => true
  validates :project,         :presence => true
  validates :charge_account,  :presence => true
end
