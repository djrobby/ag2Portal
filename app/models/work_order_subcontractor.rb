class WorkOrderSubcontractor < ActiveRecord::Base
  belongs_to :work_order
  belongs_to :supplier
  belongs_to :purchase_order
  belongs_to :charge_account
  attr_accessor :thing_supplier, :thing_order
  attr_accessible :enforcement_pct, :work_order_id, :supplier_id, :purchase_order_id, :thing_supplier, :thing_order,
                  :charge_account_id

  has_paper_trail

  #validates :work_order,      :presence => true
  validates :supplier,        :presence => true
  validates :purchase_order,  :presence => true
  validates :charge_account,  :presence => true

  #
  # Calculated fields
  #
  def cost
    if purchase_order.nil?
      0
    else
      purchase_order.taxable
    end
  end

  def costs
    (enforcement_pct / 100) * cost
  end
end
