class BudgetRatio < ActiveRecord::Base
  belongs_to :budget
  belongs_to :ratio
  attr_accessible :amount, :budget_id, :ratio_id,
                  :month_01, :month_02, :month_03, :month_04, :month_05, :month_06, :month_07, :month_08, :month_09, :month_10, :month_11, :month_12
  has_paper_trail

  #validates :budget,            :presence => true
  validates :ratio,             :presence => true
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
end
