class WorkerItem < ActiveRecord::Base
  belongs_to :worker
  belongs_to :company
  belongs_to :office
  belongs_to :professional_group
  belongs_to :collective_agreement
  belongs_to :contract_type
  belongs_to :department
  belongs_to :insurance
  attr_accessible :contribution_account_code, :ending_at, :issue_starting_at, :nomina_id, :position, :starting_at,
                  :worker_id, :company_id, :office_id, :professional_group_id, :collective_agreement_id,
                  :contract_type_id, :department_id, :insurance_id

  has_many :worker_salaries

  has_paper_trail

  validates :worker,                    :presence => true
  validates :company,                   :presence => true
  validates :office,                    :presence => true
  validates :professional_group,        :presence => true
  validates :collective_agreement,      :presence => true
  validates :contract_type,             :presence => true
  validates :starting_at,               :presence => true
  validates :issue_starting_at,         :presence => true
  validates :contribution_account_code, :presence => true
  validates :department,                :presence => true

  before_destroy :check_for_dependent_records

  def to_label
    "#{id} - #{worker.full_name}"
  end

  def years_worked
    if ending_at.blank?
      (Date.current - issue_starting_at).round / 365
    else
      (ending_at - issue_starting_at).round / 365
    end
  end

  def active?
    ending_at.blank?
  end

  #
  # Class (self) user defined methods
  #
  def self.actives(_office_id=nil)
    if _office_id.nil?
      where(ending_at: nil)
    else
      where(ending_at: nil, office_id: _office_id)
    end
  end

  # Sunspot search
  searchable do
    text :contribution_account_code
    integer :company_id
    integer :office_id
    integer :id
  end

  private

  def check_for_dependent_records
    # Check for salaries
    if worker_salaries.count > 0
      errors.add(:base, I18n.t('activerecord.models.worker_item.check_for_salaries'))
      return false
    end
  end
end
