class Client < ActiveRecord::Base
  belongs_to :entity
  belongs_to :street_type
  belongs_to :zipcode
  belongs_to :town
  belongs_to :province
  belongs_to :region
  belongs_to :country
  attr_accessible :active, :building, :cellular, :client_code, :email, :fax, :fiscal_id, :floor, :floor_office,
                  :name, :phone, :remarks, :street_name, :street_number,
                  :entity_id, :street_type_id, :zipcode_id, :town_id, :province_id, :region_id, :country_id

  has_many :delivery_notes

  has_paper_trail

  validates :name,        :presence => true
  validates :client_code, :presence => true,
                          :length => { :minimum => 6 },
                          :uniqueness => true
  validates :fiscal_id,   :presence => true,
                          :length => { :minimum => 9 },
                          :uniqueness => true
  validates :street_type, :presence => true
  validates :zipcode,     :presence => true
  validates :town,        :presence => true
  validates :province,    :presence => true
  validates :region,      :presence => true
  validates :country,     :presence => true
  validates :entity,      :presence => true

  before_validation :fields_to_uppercase

  before_destroy :check_for_dependent_records

  def fields_to_uppercase
    if !self.fiscal_id.blank?
      self[:fiscal_id].upcase!
    end
    if !self.client_code.blank?
      self[:client_code].upcase!
    end
  end

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = ""
    if !self.client_code.blank?
      full_name += self.client_code
    end
    if !self.name.blank?
      full_name += " " + self.name[0,40]
    end
    full_name
  end

  def active_yes_no
    active ? 'Yes' : 'No'
  end

  #
  # Records navigator
  #
  def to_first
    Client.order("client_code").first
  end

  def to_prev
    Client.where("client_code < ?", client_code).order("client_code").last
  end

  def to_next
    Client.where("client_code > ?", client_code).order("client_code").first
  end

  def to_last
    Client.order("client_code").last
  end

  searchable do
    text :client_code, :name, :fiscal_id, :street_name, :phone, :cellular, :email
    string :client_code
  end

  private

  def check_for_dependent_records
    # Check for delivery notes
    if delivery_notes.count > 0
      errors.add(:base, I18n.t('activerecord.models.client.check_for_delivery_notes'))
      return false
    end
    # Check for invoices
    if delivery_notes.count > 0
      errors.add(:base, I18n.t('activerecord.models.client.check_for_client_invoices'))
      return false
    end
    # Check for charges
    if delivery_notes.count > 0
      errors.add(:base, I18n.t('activerecord.models.client.check_for_client_charges'))
      return false
    end
  end
end
