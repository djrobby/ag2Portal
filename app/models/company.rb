class Company < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_companies
  belongs_to :province
  belongs_to :town
  belongs_to :zipcode
  belongs_to :street_type
  belongs_to :organization
  attr_accessible :fiscal_id, :name,
                  :street_type_id, :street_name, :street_number, :building, :floor, :floor_office,
                  :zipcode_id, :town_id, :province_id, :phone, :fax, :cellular, :email, :logo,
                  :invoice_code, :invoice_header, :invoice_footer, :invoice_left_margin,
                  :created_by, :updated_by, :organization_id, :hd_email, :website,
                  :max_order_total, :max_order_price, :overtime_pct, :commercial_bill_code
  has_attached_file :logo, :styles => { :original => "160x160>", :medium => "120x120>", :small => "80x80>" }, :default_url => "/images/missing/:style/company.png"
  attr_accessible :company_notifications_attributes

  has_many :offices
  has_many :workers
  has_many :worker_items
  has_many :corp_contacts, :order => 'last_name, first_name'
  has_many :projects
  has_many :company_notifications, dependent: :destroy
  has_many :stores
  has_many :product_company_prices
  has_many :product_valued_stock_by_companies
  has_many :infrastructures
  has_many :meters
  has_many :subscribers, through: :offices
  has_many :service_points

  # Nested attributes
  accepts_nested_attributes_for :company_notifications,
                                :reject_if => :all_blank,
                                :allow_destroy => true

  has_paper_trail

  validates :name,                  :presence => true
  validates :fiscal_id,             :presence => true,
                                    :length => { :minimum => 8 },
                                    :uniqueness => { :scope => :organization_id }
  validates :street_type,           :presence => true
  validates :zipcode,               :presence => true
  validates :town,                  :presence => true
  validates :province,              :presence => true
  validates :invoice_code,          :presence => true,
                                    :length => { :minimum => 2, :maximum => 3 },
                                    :uniqueness => { :scope => :organization_id }
  validates :commercial_bill_code,  :length => { :minimum => 2, :maximum => 3 }, :if => "!commercial_bill_code.blank?",
                                    :uniqueness => { :scope => :organization_id }
  validates :organization,          :presence => true

  validates_attachment_content_type :logo, :content_type => /\Aimage\/.*\Z/

  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records

  def fields_to_uppercase
    if !self.fiscal_id.blank?
      self[:fiscal_id].upcase!
    end
    if !self.invoice_code.blank?
      self[:invoice_code].upcase!
    end
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

  def email_and_website
    _ret = ""
    if !self.email.blank?
      _ret += self.email.strip
    end
    if !self.website.blank?
      _ret += _ret.blank? ? self.website.strip : " - " + self.website.strip
    end
    _ret
  end

  def phone_and_fax
    _ret = ""
    if !self.phone.blank?
      _ret += I18n.t("activerecord.attributes.company.phone_c") + ": " + self.phone.strip
    end
    if !self.fax.blank?
      _ret += _ret.blank? ? I18n.t("activerecord.attributes.company.fax") + ": " + self.fax.strip : " / " + I18n.t("activerecord.attributes.company.fax") + ": " + self.fax.strip
    end
    _ret
  end

  private

  def check_for_dependent_records
    # Check for offices
    if offices.count > 0
      errors.add(:base, I18n.t('activerecord.models.company.check_for_offices'))
      return false
    end
    # Check for workers
    if workers.count > 0
      errors.add(:base, I18n.t('activerecord.models.company.check_for_workers'))
      return false
    end
    # Check for corp contacts
    if corp_contacts.count > 0
      errors.add(:base, I18n.t('activerecord.models.company.check_for_contacts'))
      return false
    end
    # Check for projects
    if projects.count > 0
      errors.add(:base, I18n.t('activerecord.models.company.check_for_projects'))
      return false
    end
  end
end
