class Instalment < ActiveRecord::Base
  belongs_to :instalment_plan
  belongs_to :bill
  belongs_to :invoice
  attr_accessible :amount, :instalment, :payday_limit, :surcharge

  validates :code,  :presence => true
  validates :name,  :presence => true
  validates :type,  :presence => true

  #
  # Calculated fields
  #
  def total
    amount + surcharge
  end

  def amount_collected
  end

  def surcharge_collected
  end

  def amount_debt
  end

  def surcharge_debt
  end

  def debt
  end
end
