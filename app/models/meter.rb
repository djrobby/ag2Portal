class Meter < ActiveRecord::Base
  belongs_to :meter_model
  belongs_to :caliber
  belongs_to :meter_owner
  belongs_to :organization
  belongs_to :company
  belongs_to :office
  attr_accessible :expiry_date, :first_installation_date, :last_withdrawal_date, :manufacturing_date, :manufacturing_year, :meter_code, :purchase_date,
                  :meter_model_id, :caliber_id, :meter_owner_id, :organization_id, :company_id, :office_id,
                  :created_by, :updated_by

  has_many :meter_details, dependent: :destroy
  has_many :work_orders
  has_many :readings
  has_many :subscribers

  has_paper_trail

  validates :meter_model,         :presence => true
  validates :caliber,             :presence => true
  validates :meter_owner,         :presence => true
  validates :organization,        :presence => true
  validates :meter_code,          :presence => true,
                                  :length => { :minimum => 4, :maximum => 20 },
                                  :uniqueness => { :scope => :organization_id },
                                  :format => { with: /\A[a-zA-Z\d]+\Z/, message: :code_invalid }
  validates :manufacturing_year,  :presence => true,
                                  :length => { :is => 4 },
                                  :numericality => { :only_integer => true, :greater_than => 0 }


  # Scopes
  scope :by_code, -> { order(:meter_code) }
  scope :from_office, ->(office_id) { where(office_id: office_id).by_code }
  # BAD, it's too slow!!
  # scope :availables, ->(old_subscriber_meter=nil) { select{|m| m.subscribers.empty? or m.id == old_subscriber_meter} }
  # BETTER, only one SELECT from DB is faster
  scope :availables, ->(old_subscriber_meter_id=nil) {
    joins("LEFT JOIN `subscribers` ON subscribers.meter_id=meters.id")
    .select("meters.*")
    .where("(subscribers.meter_id IS NULL OR subscribers.meter_id=0) OR meters.id = ?", old_subscriber_meter_id)
    .by_code
  }
  scope :availables_by_caliber, ->(old_subscriber_meter_id=nil,cal) {
    joins("LEFT JOIN `subscribers` ON subscribers.meter_id=meters.id")
    .select("meters.*")
    .where("((subscribers.meter_id IS NULL OR subscribers.meter_id=0) AND meters.caliber_id = ?) OR meters.id = ?", cal, old_subscriber_meter_id)
    .by_code
  }

  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records

  def details
    if subscribers.first.blank? || subscribers.first.reading_route.blank?
      "N/A"
    else
      subscribers.first.reading_route.to_label unless subscribers.first.reading_route.blank?
    end
  end

  def order_route
    if subscribers.first.blank? || subscribers.first.reading_route.blank?
      0
    else
      subscribers.first.reading_route_id
    end
  end

  def fields_to_uppercase
    if !self.meter_code.blank?
      self[:meter_code].upcase!
    end
  end

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = ""
    if !self.meter_code.blank?
      full_name += self.meter_code
    end
    if !self.meter_model.blank?
      full_name += " " + self.meter_model.full_name
    end
    if !self.caliber.blank?
      full_name += " " + self.caliber.caliber.to_s
    end
    full_name
  end

  def is_installed_now?
    !first_installation_date.blank? && last_withdrawal_date.blank?
  end

  def assigned_to_subscriber?
    !subscribers.empty?
  end

  #
  # Class (self) user defined methods
  #
  def self.filter_organization(session, current_user)
    if session != '0'
      Meter.where(organization_id: session.to_i)
    elsif current_user.organizations.count > 0
      Meter.where(organization_id: current_user.organizations.map(&:id))
    else
      Meter.all
    end
  end

  #
  # Records navigator
  #
  def to_first
    Meter.order("meter_code").first
  end

  def to_prev
    Meter.where("meter_code < ?", meter_code).order("meter_code").last
  end

  def to_next
    Meter.where("meter_code > ?", meter_code).order("meter_code").first
  end

  def to_last
    Meter.order("meter_code").last
  end

  searchable do
    text :meter_code
    string :meter_code
    integer :office_id
    integer :organization_id
    integer :meter_model_id
    integer :meter_brand_id do
      meter_model.meter_brand_id
    end
    boolean :assigned_to_subscriber do
      assigned_to_subscriber?
    end
    integer :caliber_id
    integer :meter_owner_id
    date :purchase_date
    string :meter_code_s, :multiple => true do   # Multiple search values accepted in one search (inverse_no_search)
      meter_code
    end
  end

  private

  # Before destroy
  def check_for_dependent_records
    # Check for work orders
    if work_orders.count > 0
      errors.add(:base, I18n.t('activerecord.models.meter.check_for_work_orders'))
      return false
    end
    # Check for subscriber
    if !subscriber.blank?
      errors.add(:base, I18n.t('activerecord.models.meter.check_for_subscribers'))
      return false
    end
    # Check for readings
    if readings.count > 0
      errors.add(:base, I18n.t('activerecord.models.meter.check_for_readings'))
      return false
    end
  end
end
