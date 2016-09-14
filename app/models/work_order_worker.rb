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
  validates :charge_account,  :presence => true

  # Scopes
  scope :by_id, -> { order(:id) }
  #
  scope :belongs_to_work_order, -> work_order { where("work_order_id = ?", work_order).by_id }

  #
  # Calculated fields
  #
  def costs
    hours * cost
  end
end
