class Entity < ActiveRecord::Base
  belongs_to :street_type
  belongs_to :zipcode
  belongs_to :town
  belongs_to :province
  belongs_to :region
  belongs_to :country
  belongs_to :entity_type
  attr_accessible :building, :cellular, :company, :email, :extension, :fax, :first_name, :fiscal_id,
                  :floor, :floor_office, :last_name, :phone, :street_name, :street_number, :town,
                  :entity_type_id, :street_type_id, :zipcode_id, :town_id, :province_id, :region_id, :country_id,
                  :created_by, :updated_by

  has_paper_trail

  validates :first_name,   :presence => true, :if => "company.blank?"
  validates :last_name,    :presence => true, :if => "company.blank?"
  validates :fiscal_id,    :presence => true,
                           :length => { :minimum => 9 },
                           :uniqueness => true
  validates :street_type,  :presence => true
  validates :zipcode,      :presence => true
  validates :town,         :presence => true
  validates :province,     :presence => true
  validates :region,       :presence => true
  validates :country,      :presence => true
  validates :entity_type,  :presence => true

  before_validation :fields_to_uppercase

  before_destroy :check_for_dependent_records
  after_update :update_dependent_records

  has_one :supplier
  #has_many :customers
  def fields_to_uppercase
    if !self.fiscal_id.blank?
      self[:fiscal_id].upcase!
    end
  end

  def full_name
    full_name = ""
    if !self.last_name.blank?
    full_name += self.last_name
    end
    if !self.first_name.blank?
      full_name += ", " + self.first_name
    end
    full_name
  end

  def to_label
    if !self.last_name.blank? && !self.first_name.blank?
      "#{fiscal_id}: #{last_name}, #{first_name}"
    else
      "#{fiscal_id}: #{company}"
    end
  end

  #
  # Records navigator
  #
  def to_first
    Entity.order("fiscal_id").first
  end

  def to_prev
    Entity.where("fiscal_id < ?", fiscal_id).order("fiscal_id").last
  end

  def to_next
    Entity.where("fiscal_id > ?", fiscal_id).order("fiscal_id").first
  end

  def to_last
    Entity.order("fiscal_id").last
  end

  private

  def check_for_dependent_records
    # Check for suppliers
    if !supplier.nil?
      errors.add(:base, I18n.t('activerecord.models.entity.check_for_suppliers'))
      return false
    end
    # Check for customers
#    if customers.count > 0
#      errors.add(:base, I18n.t('activerecord.models.entity.check_for_customers'))
#      return false
#    end
  end

  def update_dependent_records
    if !supplier.nil?
      # Update linked supplier
      if entity_type_id < 2
        supplier.name = full_name
      else
        supplier.name = company
      end
      supplier.street_type_id = street_type_id
      supplier.street_name = street_name
      supplier.street_number = street_number
      supplier.building = building
      supplier.floor = floor
      supplier.floor_office = floor_office
      supplier.zipcode_id = zipcode_id
      supplier.town_id = town_id
      supplier.province_id = province_id
      supplier.region_id = region_id
      supplier.country_id = country_id
      supplier.phone = phone
      supplier.fax = fax
      supplier.cellular = cellular
      supplier.email = email
      
      if !supplier.save
        errors.add(:base, I18n.t('activerecord.models.entity.update_suppliers'))
        #return false
      end
    end
#    if customers.count > 0
      # Update linked customers
#    end
  end

  searchable do
    text :first_name, :last_name, :company, :fiscal_id, :cellular, :phone, :email, :street_name
    string :company
    string :last_name
    string :first_name
    string :fiscal_id
  end
end
