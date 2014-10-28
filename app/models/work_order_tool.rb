class WorkOrderTool < ActiveRecord::Base
  belongs_to :work_order
  belongs_to :tool
  attr_accessible :cost, :minutes, :work_order_id, :tool_id

  has_paper_trail

  validates :work_order,  :presence => true
  validates :tool,        :presence => true

  #
  # Calculated fields
  #
  def costs
    minutes * cost
  end
end