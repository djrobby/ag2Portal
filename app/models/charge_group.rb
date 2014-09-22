class ChargeGroup < ActiveRecord::Base
  belongs_to :organization
  belongs_to :budget_heading
  attr_accessible :flow, :group_code, :ledger_account, :name, :organization_id, :budget_heading_id

  has_many :charge_accounts

  has_paper_trail

  validates :group_code,      :presence => true,
                              :length => { :is => 4 },
                              :format => { with: /\A\d+\Z/, message: :code_invalid },
                              :numericality => { :only_integer => true, :greater_than => 0 },
                              :uniqueness => { :scope => :organization_id }
  validates :name,            :presence => true
  validates :flow,            :presence => true,
                              :numericality => { :only_integer => true, :greater_than => 0, :less_than_or_equal_to => 3 }
  validates :organization,    :presence => true
  validates :budget_heading,  :presence => true

  before_destroy :check_for_dependent_records

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = ''
    if !self.group_code.blank?
      full_name += self.group_code
    end
    if !self.name.blank?
      full_name += " " + self.name[0,40]
    end
    full_name
  end

  def flow_label
    flow_label = case flow
      when 1 then I18n.t('activerecord.attributes.charge_group.flow_1')       #Income
      when 2 then I18n.t('activerecord.attributes.charge_group.flow_2')       #Expenditure
      when 3 then I18n.t('activerecord.attributes.charge_group.flow_3_show')  #Both
      else 'N/A'
    end
  end

  #
  # Records navigator
  #
  def to_first
    ChargeGroup.order("group_code").first
  end

  def to_prev
    ChargeGroup.where("group_code < ?", id).order("group_code").last
  end

  def to_next
    ChargeGroup.where("group_code > ?", id).order("group_code").first
  end

  def to_last
    ChargeGroup.order("group_code").last
  end

  private

  def check_for_dependent_records
    # Check for charge accounts
    if charge_accounts.count > 0
      errors.add(:base, I18n.t('activerecord.models.charge_group.check_for_charge_accounts'))
      return false
    end
  end
end
