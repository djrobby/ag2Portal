class BankAccountClass < ActiveRecord::Base
  # CONSTANTS (right)
  SERVICIO = 1
  CONTRATACION = 2
  FRACCIONAMIENTO = 3
  TCA = 4
  TODAS = 5
  PROVEEDOR = 6
  OTRAS = 7

  attr_accessible :name

  has_many :supplier_bank_accounts

  has_paper_trail

  validates :name,  :presence => true

  before_destroy :check_for_dependent_records

  private

  def check_for_dependent_records
    # Check for supplier bank accounts
    if supplier_bank_accounts.count > 0
      errors.add(:base, I18n.t('activerecord.models.bank_account_class.check_for_supplier_bank_accounts'))
      return false
    end
    # Check for client bank accounts
    if client_bank_accounts.count > 0
      errors.add(:base, I18n.t('activerecord.models.bank_account_class.check_for_client_bank_accounts'))
      return false
    end
  end
end
