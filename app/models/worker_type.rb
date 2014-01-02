class WorkerType < ActiveRecord::Base
  attr_accessible :description,
                  :created_by, :updated_by

  has_many :workers

  has_paper_trail

  validates :description, :presence => true

  before_destroy :check_for_workers
  
  def to_label
    "#{description.titleize}"
  end

  private

  def check_for_workers
    # Check for worker items
    if workers.count > 0
      errors.add(:base, I18n.t('activerecord.models.worker_type.check_for_workers'))
      return false
    end
  end
end
