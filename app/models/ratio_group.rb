class RatioGroup < ActiveRecord::Base
  belongs_to :organization
  attr_accessible :code, :name, :organization_id
  has_many :ratios

  has_paper_trail

  validates :code,          :presence => true,
                            :length => { :is => 4 },
                            :format => { with: /\A\d+\Z/, message: :code_invalid },
                            :numericality => { :only_integer => true, :greater_than => 0 },
                            :uniqueness => { :scope => :organization_id }
  validates :name,          :presence => true
  validates :organization,  :presence => true
  
  before_destroy :check_for_ratios

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = code.blank? ? "" : code.strip
    if !self.name.blank?
      full_name += " " + self.name[0,40]
    end
    full_name
  end

  private
  
  def check_for_ratios
    if ratios.count > 0
      errors.add(:base, I18n.t('activerecord.models.ratio_group.check_for_ratios'))
      return false
    end
  end
end
