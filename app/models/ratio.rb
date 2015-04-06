class Ratio < ActiveRecord::Base
  belongs_to :organization
  belongs_to :ratio_group
  attr_accessible :code, :formula, :name, :organization_id, :ratio_group_id
  #has_many :budget_ratios

  has_paper_trail

  validates :code,          :presence => true,
                            :length => { :is => 11 },
                            :format => { with: /\A\d+\Z/, message: :code_invalid },
                            :numericality => { :only_integer => true, :greater_than => 0 },
                            :uniqueness => { :scope => :organization_id }
  validates :name,          :presence => true
  validates :organization,  :presence => true
  validates :ratio_group,   :presence => true

  before_destroy :check_for_budget_ratios

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = full_code
    if !self.name.blank?
      full_name += " " + self.name[0,40]
    end
    full_name
  end

  def full_code
    # Ratio code (Group code & sequential number) => OOOO-NNNNNNN
    code.blank? ? "" : code[0..3] + '-' + code[4..10]
  end

  def partial_name
    name.blank? ? "" : self.name[0,30]
  end

  def partial_group_name
    ratio_group.blank? ? "" : ratio_group.name[0,30]
  end

  searchable do
    text :code, :name
    string :code
    integer :ratio_group_id
    integer :organization_id
  end

  private
  
  def check_for_budget_ratios
    if budget_ratios.count > 0
      errors.add(:base, I18n.t('activerecord.models.ratio_group.check_for_budget_ratios'))
      return false
    end
  end
end
