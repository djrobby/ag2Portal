class BudgetHeading < ActiveRecord::Base
  belongs_to :organization
  attr_accessible :heading_code, :name, :organization_id

  has_many :charge_groups

  has_paper_trail

  validates :heading_code,    :presence => true,
                              :length => { :is => 4 },
                              :format => { with: /\A\d+\Z/, message: :code_invalid },
                              :numericality => { :only_integer => true, :greater_than => 0 },
                              :uniqueness => { :scope => :organization_id }
  validates :name,            :presence => true,
                              :length => { :in => 5..40 }
  validates :organization,    :presence => true

  before_destroy :check_for_dependent_records

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = ''
    if !self.heading_code.blank?
      full_name += self.heading_code
    end
    if !self.name.blank?
      full_name += " " + self.name
    end
    full_name
  end

  #
  # Records navigator
  #
  def to_first
    BudgetHeading.order("heading_code").first
  end

  def to_prev
    BudgetHeading.where("heading_code < ?", id).order("heading_code").last
  end

  def to_next
    BudgetHeading.where("heading_code > ?", id).order("heading_code").first
  end

  def to_last
    BudgetHeading.order("heading_code").last
  end

  private

  def check_for_dependent_records
    # Check for charge groups
    if charge_groups.count > 0
      errors.add(:base, I18n.t('activerecord.models.budget_heading.check_for_charge_groups'))
      return false
    end
  end
end
