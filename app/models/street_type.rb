class StreetType < ActiveRecord::Base
  attr_accessible :street_type_code, :street_type_description,
                  :created_by, :updated_by

  has_many :companies
  has_many :offices
  has_many :workers
  has_many :shared_contacts
  has_many :entities
  has_many :suppliers
  has_many :clients

  has_paper_trail

  validates :street_type_description, :presence => true
  validates :street_type_code,        :presence => true,
                                      :length => { :minimum => 2 },
                                      :uniqueness => true

  before_validation :street_type_code_to_uppercase
  before_destroy :check_for_dependent_records
  
  def street_type_code_to_uppercase
    self[:street_type_code].upcase!
  end

  def to_label
    "#{street_type_code} (#{street_type_description.titleize})"
  end

  private

  def check_for_dependent_records
    # Check for companies
    if companies.count > 0
      errors.add(:base, I18n.t('activerecord.models.street_type.check_for_companies'))
      return false
    end
    # Check for offices
    if offices.count > 0
      errors.add(:base, I18n.t('activerecord.models.street_type.check_for_offices'))
      return false
    end
    # Check for workers
    if workers.count > 0
      errors.add(:base, I18n.t('activerecord.models.street_type.check_for_workers'))
      return false
    end
    # Check for shared contacts
    if shared_contacts.count > 0
      errors.add(:base, I18n.t('activerecord.models.street_type.check_for_contacts'))
      return false
    end
    # Check for entities
    if entities.count > 0
      errors.add(:base, I18n.t('activerecord.models.street_type.check_for_entities'))
      return false
    end
    # Check for suppliers
    if suppliers.count > 0
      errors.add(:base, I18n.t('activerecord.models.street_type.check_for_suppliers'))
      return false
    end
    # Check for clients
    if clients.count > 0
      errors.add(:base, I18n.t('activerecord.models.street_type.check_for_clients'))
      return false
    end
  end
end
