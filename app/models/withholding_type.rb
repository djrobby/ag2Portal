class WithholdingType < ActiveRecord::Base
  belongs_to :ledger_account
  attr_accessible :description, :expiration, :tax, :ledger_account_app_code, :ledger_account_id

  has_many :suppliers

  has_paper_trail

  validates :description, :presence => true
  validates :tax,         :presence => true

  # Scopes
  scope :current, -> { where("expiration >= ? OR expiration IS NULL", Date.today).order('tax') }
  scope :expired, -> { where("NOT expiration IS NULL AND expiration < ?", Date.today).order('tax') }

  before_destroy :check_for_dependent_records

  def to_label
    "#{description} (#{tax})"
  end

  def ledger_account_app_code_formatted
    ledger_account_app_code.blank? ? '' : ledger_account_app_code
  end

  def ledger_account_code
    ledger_account.blank? ? '475100922' : ledger_account.code
  end

  private

  def check_for_dependent_records
    # Check for suppliers
    if suppliers.count > 0
      errors.add(:base, I18n.t('activerecord.models.tax_type.check_for_suppliers'))
      return false
    end
  end
end
