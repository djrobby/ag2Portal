class InstalmentPlan < ActiveRecord::Base
  belongs_to :payment_method
  belongs_to :client
  belongs_to :subscriber
  attr_accessible :instalment_date, :instalment_no, :surcharge_pct

  has_many :instalments, dependent: :destroy

  validates :instalment_no,   :presence => true
  validates :instalment_date, :presence => true
  validates :payment_method,  :presence => true
  validates :client,          :presence => true

  #
  # Calculated fields
  #
  def instalments_qty
    instalments.count
  end

  def subtotal
  end

  def surcharges
  end

  def total
  end

  def collected
  end

  def debt
  end
end
