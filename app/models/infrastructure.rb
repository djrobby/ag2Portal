class Infrastructure < ActiveRecord::Base
  belongs_to :infrastructure_type
  belongs_to :organization
  belongs_to :company
  belongs_to :office
  attr_accessible :name, :infrastructure_type_id, :organization_id,
                  :company_id, :office_id

  has_many :work_orders

  has_paper_trail

  validates :name,                :presence => true
  validates :infrastructure_type, :presence => true
  validates :organization,        :presence => true

  before_destroy :check_for_dependent_records

  private

  def check_for_dependent_records
    # Check for work orders
    if work_orders.count > 0
      errors.add(:base, I18n.t('activerecord.models.infrastructure.check_for_work_orders'))
      return false
    end
  end
end
