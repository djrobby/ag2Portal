class Town < ActiveRecord::Base
  belongs_to :province
  attr_accessible :ine_cmun, :ine_dc, :name, :province_id
  delegate :name, :to => :province, :allow_nil => true, :prefix => true

  has_many :zipcodes
  has_many :companies
  has_many :offices
  has_many :workers
  has_many :shared_contacts
  has_many :entities
  has_many :suppliers
  has_many :clients
  has_many :street_directories
  has_many :contract_templates
  has_many :contract_template_terms, through: :contract_templates

  has_paper_trail

  validates :name,      :presence => true
  validates :province,  :presence => true
  validates :ine_cmun,  :length => { :minimum => 3 }
  validates :ine_dc,    :length => { :minimum => 1 }

  # Scopes
  scope :by_ine, -> { order(:ine_cmun, :ine_dc) }
  scope :by_name, -> { order(:name) }

  # Callbacks
  before_destroy :check_for_dependent_records

  def to_label
    "#{name} (#{province.name})"
  end

  private

  def check_for_dependent_records
    # Check for zipcodes
    if zipcodes.count > 0
      errors.add(:base, I18n.t('activerecord.models.town.check_for_zipcodes'))
      return false
    end
    # Check for companies
    if companies.count > 0
      errors.add(:base, I18n.t('activerecord.models.town.check_for_companies'))
      return false
    end
    # Check for offices
    if offices.count > 0
      errors.add(:base, I18n.t('activerecord.models.town.check_for_offices'))
      return false
    end
    # Check for workers
    if workers.count > 0
      errors.add(:base, I18n.t('activerecord.models.town.check_for_workers'))
      return false
    end
    # Check for shared contacts
    if shared_contacts.count > 0
      errors.add(:base, I18n.t('activerecord.models.town.check_for_contacts'))
      return false
    end
    # Check for entities
    if entities.count > 0
      errors.add(:base, I18n.t('activerecord.models.town.check_for_entities'))
      return false
    end
    # Check for suppliers
    if suppliers.count > 0
      errors.add(:base, I18n.t('activerecord.models.town.check_for_suppliers'))
      return false
    end
    # Check for clients
    if clients.count > 0
      errors.add(:base, I18n.t('activerecord.models.town.check_for_clients'))
      return false
    end
  end
end
