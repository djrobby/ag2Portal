class Zipcode < ActiveRecord::Base
  belongs_to :town
  belongs_to :province
  attr_accessible :zipcode, :town_id, :province_id,
                  :created_by, :updated_by


  has_many :companies
  has_many :offices
  has_many :workers
  has_many :shared_contacts
  has_many :entities
  has_many :suppliers
  has_many :clients

  has_paper_trail

  validates :zipcode,   :presence => true,
                        :uniqueness => true
  validates :town,      :presence => true
  validates :province,  :presence => true

  before_destroy :check_for_dependent_records

  def to_label
    "#{zipcode} - #{town.name} (#{province.name})"
  end

  def town_name
    town.name
  end

  searchable do
    text :zipcode, :town_name
    string :zipcode
    integer :town_id
    integer :province_id
  end

  private

  def check_for_dependent_records
    # Check for companies
    if companies.count > 0
      errors.add(:base, I18n.t('activerecord.models.zipcode.check_for_companies'))
      return false
    end
    # Check for offices
    if offices.count > 0
      errors.add(:base, I18n.t('activerecord.models.zipcode.check_for_offices'))
      return false
    end
    # Check for workers
    if workers.count > 0
      errors.add(:base, I18n.t('activerecord.models.zipcode.check_for_workers'))
      return false
    end
    # Check for shared contacts
    if shared_contacts.count > 0
      errors.add(:base, I18n.t('activerecord.models.zipcode.check_for_contacts'))
      return false
    end
    # Check for entities
    if entities.count > 0
      errors.add(:base, I18n.t('activerecord.models.zipcode.check_for_entities'))
      return false
    end
    # Check for suppliers
    if suppliers.count > 0
      errors.add(:base, I18n.t('activerecord.models.zipcode.check_for_suppliers'))
      return false
    end
    # Check for clients
    if clients.count > 0
      errors.add(:base, I18n.t('activerecord.models.zipcode.check_for_clients'))
      return false
    end
  end
end
