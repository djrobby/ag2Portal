class Country < ActiveRecord::Base
  attr_accessible :name, :code, :prefix,
                  :created_by, :updated_by

  has_many :shared_contacts
  has_many :regions
  has_many :entities
  has_many :suppliers
  has_many :clients
  has_many :supplier_bank_accounts
  has_many :client_bank_accounts

  has_paper_trail

  validates :name,  :presence => true
  validates :code,  :presence => true,
                    :length => { :is => 2 },
                    :uniqueness => true

  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records

  def fields_to_uppercase
    if !self.code.blank?
      self[:code].upcase!
    end
  end

  def full_name
    full_name = ""
    if !self.code.blank?
      full_name += self.code
    end
    if !self.name.blank?
      full_name += " " + self.name
    end
    full_name
  end

  private

  def check_for_dependent_records
    # Check for regions
    if regions.count > 0
      errors.add(:base, I18n.t('activerecord.models.country.check_for_regions'))
      return false
    end
    # Check for shared contacts
    if shared_contacts.count > 0
      errors.add(:base, I18n.t('activerecord.models.country.check_for_contacts'))
      return false
    end
    # Check for entities
    if entities.count > 0
      errors.add(:base, I18n.t('activerecord.models.country.check_for_entities'))
      return false
    end
    # Check for suppliers
    if suppliers.count > 0
      errors.add(:base, I18n.t('activerecord.models.country.check_for_suppliers'))
      return false
    end
    # Check for clients
    if clients.count > 0
      errors.add(:base, I18n.t('activerecord.models.country.check_for_clients'))
      return false
    end
    # Check for supplier bank accounts
    if supplier_bank_accounts.count > 0
      errors.add(:base, I18n.t('activerecord.models.country.check_for_supplier_bank_accounts'))
      return false
    end
    # Check for client bank accounts
    if client_bank_accounts.count > 0
      errors.add(:base, I18n.t('activerecord.models.country.check_for_client_bank_accounts'))
      return false
    end
  end
end
