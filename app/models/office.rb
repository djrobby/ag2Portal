class Office < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_offices
  belongs_to :company
  belongs_to :province
  belongs_to :town
  belongs_to :zipcode
  belongs_to :street_type
  belongs_to :zone
  belongs_to :water_supply_contract_template, class_name: "ContractTemplate", foreign_key: "water_supply_contract_template_id"
  belongs_to :water_connection_contract_template, class_name: "ContractTemplate", foreign_key: "water_connection_contract_template_id"

  attr_accessible :name, :company_id, :office_code, :zone_id,
                  :street_type_id, :street_name, :street_number, :building, :floor, :floor_office,
                  :zipcode_id, :town_id, :province_id, :phone, :fax, :cellular, :email,
                  :created_by, :updated_by, :nomina_id, :max_order_total, :max_order_price, :overtime_pct,
                  :r_last_name, :r_first_name, :r_fiscal_id, :r_position,
                  :water_supply_contract_template_id, :water_connection_contract_template_id
  attr_accessible :office_notifications_attributes

  has_many :workers
  has_many :worker_items
  has_many :corp_contacts, :order => 'last_name, first_name'
  has_many :tickets
  has_many :projects
  has_many :office_notifications, dependent: :destroy
  has_many :infrastructures
  has_many :meters
  has_many :subscribers
  has_many :service_points

  # Nested attributes
  accepts_nested_attributes_for :office_notifications,
                                :reject_if => :all_blank,
                                :allow_destroy => true

  has_paper_trail

  validates :name,         :presence => true
  validates :company,      :presence => true
  validates :office_code,  :presence => true,
                           :length => { :minimum => 5, :maximum => 8 },
                           :uniqueness => true
  validates :street_type,  :presence => true
  validates :zipcode,      :presence => true
  validates :town,         :presence => true
  validates :province,     :presence => true

  before_destroy :check_for_dependent_records

  def to_label
    "#{name} (#{company.name})"
  end

  def address_1
    _ret = ""
    if !street_type.blank?
      _ret += street_type.street_type_code.titleize + ". "
    end
    if !street_name.blank?
      _ret += street_name + " "
    end
    if !street_number.blank?
      _ret += street_number + ", "
    end
    if !building.blank?
      _ret += building.titleize + ", "
    end
    if !floor.blank?
      _ret += floor_human + " "
    end
    if !floor_office.blank?
      _ret += floor_office
    end
    _ret
  end

  def address_2
    _ret = ""
    if !zipcode.blank?
      _ret += zipcode.zipcode + " "
    end
    if !town.blank?
      _ret += town.name + ", "
    end
    if !province.blank?
      _ret += province.name + " "
      if !province.region.country.blank?
        _ret += "(" + province.region.country.name + ")"
      end
    end
    _ret
  end

  def floor_human
    _ret = floor
    _floor_is_numeric = true if Float(floor) rescue false
    if _floor_is_numeric
      _ret = floor.strip + "\xBA".force_encoding('ISO-8859-1').encode('UTF-8')
    end
    _ret
  end

  def phone_fax_email
    _ret = ""
    if !self.phone.blank?
      _ret += I18n.t("activerecord.attributes.office.phone_c") + ": " + self.phone.strip
    end
    if !self.fax.blank?
      _ret += _ret.blank? ? I18n.t("activerecord.attributes.office.fax") + ": " + self.fax.strip : " / " + I18n.t("activerecord.attributes.office.fax") + ": " + self.fax.strip
    end
    if !self.email.blank?
      _ret += _ret.blank? ? self.email.strip : " / " + self.email.strip
    end
    _ret
  end

  def r_full_name
    full_name = ""
    if !self.r_last_name.blank?
      full_name += self.r_last_name
    end
    if !self.r_first_name.blank?
      full_name += ", " + self.r_first_name
    end
    full_name[0,40]
  end

  searchable do
    text :office_code, :name
    string :office_code
    integer :town_id
    integer :province_id
    integer :company_id
    integer :organization_id do
      company.organization_id unless (company.blank? || company.organization_id.blank?)
    end
    text :company_name do
      company.name unless (company.blank? || company.name.blank?)
    end
  end

  private

  def check_for_dependent_records
    # Check for workers
    if workers.count > 0
      errors.add(:base, I18n.t('activerecord.models.office.check_for_workers'))
      return false
    end
    # Check for worker items
    if worker_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.office.check_for_workers'))
      return false
    end
    # Check for corp contacts
    if corp_contacts.count > 0
      errors.add(:base, I18n.t('activerecord.models.office.check_for_contacts'))
      return false
    end
    # Check for projects
    if projects.count > 0
      errors.add(:base, I18n.t('activerecord.models.office.check_for_projects'))
      return false
    end
    # Check for tickets
    if tickets.count > 0
      errors.add(:base, I18n.t('activerecord.models.office.check_for_tickets'))
      return false
    end
  end
end
