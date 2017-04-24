class LedgerAccount < ActiveRecord::Base
  belongs_to :accounting_group
  belongs_to :organization
  belongs_to :company
  belongs_to :project
  attr_accessible :code, :name, :accounting_group_id, :project_id, :organization_id, :company_id

  has_many :charge_accounts
  has_many :charge_groups
  has_many :suppliers
  has_many :clients
  has_many :projects
  has_many :charge_group_ledger_accounts
  has_many :charge_account_ledger_accounts
  has_many :client_ledger_accounts
  has_many :supplier_ledger_accounts

  has_paper_trail

  validates :code,              :presence => true,
                                :uniqueness => { :scope => :organization_id }
  validates :name,              :presence => true
  validates :accounting_group,  :presence => true
  validates :organization,      :presence => true

  before_destroy :check_for_dependent_records

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = code.blank? ? "" : code.strip
    if !self.name.blank?
      full_name += " " + self.name[0,50]
    end
    full_name
  end

  private

  def check_for_dependent_records
    # Check for charge accounts
    if charge_accounts.count > 0
      errors.add(:base, I18n.t('activerecord.models.ledger_account.check_for_charge_accounts'))
      return false
    end
    if charge_account_ledger_accounts.count > 0
      errors.add(:base, I18n.t('activerecord.models.ledger_account.check_for_charge_accounts'))
      return false
    end
    # Check for charge groups
    if charge_groups.count > 0
      errors.add(:base, I18n.t('activerecord.models.ledger_account.check_for_charge_groups'))
      return false
    end
    if charge_group_ledger_accounts.count > 0
      errors.add(:base, I18n.t('activerecord.models.ledger_account.check_for_charge_groups'))
      return false
    end
    # Check for suppliers
    if suppliers.count > 0
      errors.add(:base, I18n.t('activerecord.models.ledger_account.check_for_suppliers'))
      return false
    end
    if supplier_ledger_accounts.count > 0
      errors.add(:base, I18n.t('activerecord.models.ledger_account.check_for_suppliers'))
      return false
    end
    # Check for clients
    if clients.count > 0
      errors.add(:base, I18n.t('activerecord.models.ledger_account.check_for_clients'))
      return false
    end
    if client_ledger_accounts.count > 0
      errors.add(:base, I18n.t('activerecord.models.ledger_account.check_for_clients'))
      return false
    end
    # Check for projects
    if projects.count > 0
      errors.add(:base, I18n.t('activerecord.models.ledger_account.check_for_clients'))
      return false
    end
  end
end
