class WorkOrderVehicle < ActiveRecord::Base
  belongs_to :work_order
  belongs_to :vehicle
  belongs_to :charge_account
  attr_accessor :thing
  attr_accessible :cost, :distance, :work_order_id, :vehicle_id, :thing,
                  :charge_account_id

  has_paper_trail

  #validates :work_order,  :presence => true
  validates :vehicle,     :presence => true
  validates :charge_account,  :presence => true

  # Scopes
  scope :by_id, -> { order(:id) }
  #
  scope :belongs_to_work_order, -> work_order { where("work_order_id = ?", work_order).by_id }

  #
  # Calculated fields
  #
  def costs
    distance * cost
  end
end
