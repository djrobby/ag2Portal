class BudgetPeriod < ActiveRecord::Base
  belongs_to :organization
  attr_accessible :ending_at, :name, :period_code, :starting_at, :organization_id
  
  has_many :budgets

  has_paper_trail

  validates :period_code,   :presence => true,
                            :length => { :minimum => 4, :maximum => 8 },
                            :format => { with: /\A[a-zA-Z\d]+\Z/, message: :code_invalid },
                            :uniqueness => { :scope => :organization_id }
  validates :name,          :presence => true
  validates :starting_at,   :presence => true
  validates :ending_at,     :presence => true
  validates :organization,  :presence => true

  before_destroy :check_for_dependent_records

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = ''
    if !self.period_code.blank?
      full_name += self.period_code
    end
    if !self.name.blank?
      full_name += " " + self.name[0,40]
    end
    full_name
  end

  private

  def check_for_dependent_records
    # Check for budgets
    if budgets.count > 0
      errors.add(:base, I18n.t('activerecord.models.budget_period.check_for_budgets'))
      return false
    end
  end
end
