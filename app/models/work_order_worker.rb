class WorkOrderWorker < ActiveRecord::Base
  belongs_to :work_order
  belongs_to :worker
  belongs_to :charge_account
  attr_accessor :thing
  attr_accessible :cost, :hours, :work_order_id, :worker_id, :thing,
                  :charge_account_id

  has_paper_trail

  #validates :work_order,  :presence => true
  validates :worker,      :presence => true

  #
  # Calculated fields
  #
  def costs
    hours * cost
  end
end
