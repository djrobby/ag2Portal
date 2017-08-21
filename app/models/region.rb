class Region < ActiveRecord::Base
  belongs_to :country
  attr_accessible :country_id, :name,
                  :created_by, :updated_by

  has_many :provinces
  has_many :shared_contacts
  has_many :entities
  has_many :suppliers
  has_many :clients
  has_many :towns, through: :provinces
  has_many :contract_templates
  has_many :contract_template_terms, through: :contract_templates

  has_paper_trail

  validates :name,    :presence => true
  validates :country, :presence => true

  before_destroy :check_for_dependent_records

  def to_label
    "#{name} (#{country.name})"
  end

  def name_and_country
    self.name + " (" + self.country.name + ")"
  end

  private

  def check_for_dependent_records
    # Check for provinces
    if provinces.count > 0
      errors.add(:base, I18n.t('activerecord.models.region.check_for_provinces'))
      return false
    end
    # Check for entities
    if entities.count > 0
      errors.add(:base, I18n.t('activerecord.models.region.check_for_entities'))
      return false
    end
    # Check for shared contacts
    if shared_contacts.count > 0
      errors.add(:base, I18n.t('activerecord.models.region.check_for_contacts'))
      return false
    end
    # Check for suppliers
    if suppliers.count > 0
      errors.add(:base, I18n.t('activerecord.models.region.check_for_suppliers'))
      return false
    end
    # Check for clients
    if clients.count > 0
      errors.add(:base, I18n.t('activerecord.models.region.check_for_clients'))
      return false
    end
  end
end
