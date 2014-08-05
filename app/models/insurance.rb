class Insurance < ActiveRecord::Base
  belongs_to :organization
  attr_accessible :name, :organization_id

  has_many :workers
  has_many :worker_items

  has_paper_trail

  validates :name,          :presence => true
  validates :organization,  :presence => true

  before_destroy :check_for_dependent_records

  private

  def check_for_dependent_records
    # Check for worker items
    if worker_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.insurance.check_for_workers'))
      return false
    end
  end
end
