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

  #
  # Calculated fields
  #
  def costs
    distance * cost
  end
end
