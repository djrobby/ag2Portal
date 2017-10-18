# encoding: utf-8

class Province < ActiveRecord::Base
  belongs_to :region
  attr_accessible :ine_cpro, :name, :region_id,
                  :created_by, :updated_by

  validates :name,      :presence => true
  validates :ine_cpro,  :length => { :minimum => 2 }
  validates :region,    :presence => true

  has_many :towns
  has_many :zipcodes
  has_many :companies
  has_many :offices
  has_many :workers
  has_many :shared_contacts
  has_many :entities
  has_many :suppliers
  has_many :clients
  has_many :contract_templates
  has_many :contract_template_terms, through: :contract_templates

  has_paper_trail

  before_destroy :check_for_dependent_records

  def to_label
    "#{name_and_region}"
  end

  def name_and_region
    self.name + " (" + self.region.name + ")"
  end

  def name_region_country
    self.name + " (" + self.region.name_and_country + ")"
  end

  def territory_code
    _ret = '0'
    if region.name.upcase.include? 'CANARIAS'
      _ret = '1'
    elsif (region.name.upcase.include? 'EUSKADI') || (region.name.upcase.include? 'VASCO')
      if (self.name.upcase.include? 'ARABA') || (self.name.upcase.include? 'ALAVA') || (self.name.upcase.include? 'ÁLAVA')
        _ret = '2'
      elsif (self.name.upcase.include? 'BIZKAIA') || (self.name.upcase.include? 'VIZCAYA')
        _ret = '3'
      elsif (self.name.upcase.include? 'GIPUZKOA') || (self.name.upcase.include? 'GUIPUZCOA') || (self.name.upcase.include? 'GUIPÚZCOA')
        _ret = '4'
      end
    elsif region.name.upcase.include? 'NAVARRA'
      _ret = '5'
    end
    _ret
  end

  private

  def check_for_dependent_records
    # Check for towns
    if towns.count > 0
      errors.add(:base, I18n.t('activerecord.models.province.check_for_towns'))
      return false
    end
    # Check for zipcodes
    if zipcodes.count > 0
      errors.add(:base, I18n.t('activerecord.models.province.check_for_zipcodes'))
      return false
    end
    # Check for companies
    if companies.count > 0
      errors.add(:base, I18n.t('activerecord.models.province.check_for_companies'))
      return false
    end
    # Check for offices
    if offices.count > 0
      errors.add(:base, I18n.t('activerecord.models.province.check_for_offices'))
      return false
    end
    # Check for workers
    if workers.count > 0
      errors.add(:base, I18n.t('activerecord.models.province.check_for_workers'))
      return false
    end
    # Check for shared contacts
    if shared_contacts.count > 0
      errors.add(:base, I18n.t('activerecord.models.province.check_for_contacts'))
      return false
    end
    # Check for entities
    if entities.count > 0
      errors.add(:base, I18n.t('activerecord.models.province.check_for_entities'))
      return false
    end
    # Check for suppliers
    if suppliers.count > 0
      errors.add(:base, I18n.t('activerecord.models.province.check_for_suppliers'))
      return false
    end
    # Check for clients
    if clients.count > 0
      errors.add(:base, I18n.t('activerecord.models.province.check_for_clients'))
      return false
    end
  end
end
