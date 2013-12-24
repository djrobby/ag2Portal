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

  has_many :worker_salaries, dependent: :destroy

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
  
  def years_worked
    if ending_at.blank?
      (Date.current - issue_starting_at).round / 365
    else
      (ending_at - issue_starting_at).round / 365
    end
  end
end
