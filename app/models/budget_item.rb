class BudgetItem < ActiveRecord::Base
  belongs_to :budget
  belongs_to :charge_account
  attr_accessible :amount, :corrected_amount, :budget_id, :charge_account_id,
                  :month_01, :month_02, :month_03, :month_04, :month_05, :month_06,
                  :month_07, :month_08, :month_09, :month_10, :month_11, :month_12

  has_paper_trail

  validates :budget,            :presence => true
  validates :charge_account,    :presence => true
  validates :month_01,          :numericality => true
  validates :month_02,          :numericality => true
  validates :month_03,          :numericality => true
  validates :month_04,          :numericality => true
  validates :month_05,          :numericality => true
  validates :month_06,          :numericality => true
  validates :month_07,          :numericality => true
  validates :month_08,          :numericality => true
  validates :month_09,          :numericality => true
  validates :month_10,          :numericality => true
  validates :month_11,          :numericality => true
  validates :month_12,          :numericality => true
  validates :corrected_amount,  :numericality => true

  #
  # Calculated fields
  #
  # Amounts must be positive or negative based on charge_group.flow, and must be validated at data-entry!
  def annual
    if amount.blank?
      month_01 + month_02 + month_03 + month_04 + month_05 + month_06 +
      month_07 + month_08 + month_09 + month_10 + month_11 + month_12 
    else
      amount
    end
  end
end
