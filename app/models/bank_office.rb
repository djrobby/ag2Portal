class BankOffice < ActiveRecord::Base
  belongs_to :bank
  belongs_to :street_type
  belongs_to :zipcode
  belongs_to :town
  belongs_to :province
  belongs_to :region
  belongs_to :country
  attr_accessible :building, :cellular, :code, :email, :extension, :fax, :floor, :floor_office, :name, :phone,
                  :street_name, :street_number, :bank_id, :street_type_id, :zipcode_id, :town_id, :province_id,
                  :region_id, :country_id, :swift

  has_many :supplier_bank_accounts
  has_many :client_bank_accounts

  has_paper_trail

  validates :code,          :presence => true,
                            :length => { :is => 4 },
                            :format => { with: /\A\d+\Z/, message: :code_invalid },
                            :uniqueness => { :scope => :bank_id }
  validates :name,          :presence => true
  validates :swift,         :length => { :minimum => 8, :maximum => 11 }, :if => "!swift.blank?"
  validates :bank,          :presence => true
  validates :street_type,   :presence => true
  validates :zipcode,       :presence => true
  validates :town,          :presence => true
  validates :province,      :presence => true
  validates :region,        :presence => true
  validates :country,       :presence => true

  before_destroy :check_for_dependent_records

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = ""
    if !self.code.blank?
      full_name += self.code
    end
    if !self.name.blank?
      full_name += " " + self.name
    end
    if !self.bank.blank?
      full_name += " (" + self.bank.code + ")"
    end
    full_name
  end

  def full_code
    _ret = ""
    if !self.bank.blank?
      _ret += self.bank.code
    end
    if !self.code.blank?
      _ret += " " + self.code
    end
    _ret
  end

  def full_address
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
    if !zipcode.blank?
      _ret += zipcode.zipcode + " "
    end
    if !town.blank?
      _ret += town.name
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
    # Check for supplier bank accounts
    if supplier_bank_accounts.count > 0
      errors.add(:base, I18n.t('activerecord.models.bank_office.check_for_supplier_bank_accounts'))
      return false
    end
    # Check for client bank accounts
    if client_bank_accounts.count > 0
      errors.add(:base, I18n.t('activerecord.models.bank_office.check_for_client_bank_accounts'))
      return false
    end
  end
end
