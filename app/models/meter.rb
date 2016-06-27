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

  has_many :meter_details
  has_many :work_orders
  has_many :subscribers
  has_many :meter_details, dependent: :destroy

  has_paper_trail

  validates :meter_model,         :presence => true
  validates :caliber,             :presence => true
  validates :meter_owner,         :presence => true
  validates :organization,        :presence => true
  validates :meter_code,          :presence => true,
                                  :length => { :minimum => 4, :maximum => 12 },
                                  :uniqueness => { :scope => :organization_id },
                                  :format => { with: /\A[a-zA-Z\d]+\Z/, message: :code_invalid }
  validates :manufacturing_year,  :presence => true,
                                  :length => { :is => 4 },
                                  :numericality => { :only_integer => true, :greater_than => 0 }
  validates :organization,        :presence => true

  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records

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
    full_name
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
    integer :organization_id
    integer :meter_model_id
    integer :caliber_id
    integer :meter_owner_id
  end

  private

  # Before destroy
  def check_for_dependent_records
    # Check for work orders
    if work_orders.count > 0
      errors.add(:base, I18n.t('activerecord.models.meter.check_for_work_orders'))
      return false
    end
    # Check for subscribers
    if subscribers.count > 0
      errors.add(:base, I18n.t('activerecord.models.meter.check_for_subscribers'))
      return false
    end
  end
end
