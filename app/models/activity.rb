class Activity < ActiveRecord::Base
  has_and_belongs_to_many :suppliers, :join_table => :suppliers_activities
  attr_accessible :description

  has_paper_trail

  validates :description, :presence => true

  before_destroy :check_for_suppliers

  def to_label
    "#{description}"
  end

  private

  def check_for_suppliers
    if suppliers.count > 0
      errors.add(:base, I18n.t('activerecord.models.activity.check_for_suppliers'))
      return false
    end
  end
end
