class Subscriber < ActiveRecord::Base
  belongs_to :client
  belongs_to :office
  belongs_to :center
  belongs_to :street_directory
  belongs_to :zipcode
  belongs_to :service_point
  belongs_to :tariff_scheme
  belongs_to :billing_frequency
  belongs_to :meter
  belongs_to :reading_route
  belongs_to :contracting_request
  attr_accessible :company, :first_name, :fiscal_id, :last_name, :subscriber_code,
                  :starting_at, :ending_at, :created_by, :updated_by,
                  :client_id, :office_id, :center_id, :street_directory_id, :street_number,
                  :building, :floor, :floor_office, :zipcode_id, :phone, :fax, :cellular, :email,
                  :service_point_id, :active, :tariff_scheme_id, :billing_frequency_id, :meter_id,
                  :reading_route_id, :reading_sequence, :reading_variant, :contracting_request_id,
                  :remarks, :cadastral_reference, :gis_id, :endownments, :inhabitants

  has_many :work_orders

  has_paper_trail

  validates :client,            :presence => true
  validates :office,            :presence => true
  validates :center,            :presence => true
  validates :street_directory,  :presence => true
  validates :subscriber_code,   :presence => true,
                                :length => { :is => 11 },
                                :uniqueness => { :scope => :office_id },
                                :format => { with: /\A\d+\Z/, message: :code_invalid }
  validates :fiscal_id,         :presence => true,
                                :length => { :minimum => 8 }
  validates :zipcode,           :presence => true

  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records

  def fields_to_uppercase
    if !self.fiscal_id.blank?
      self[:fiscal_id].upcase!
    end
    if !self.subscriber_code.blank?
      self[:subscriber_code].upcase!
    end
  end

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = full_code
    if !self.name.blank?
      full_name += " " + self.name[0,40]
    end
    full_name
  end

  def full_code
    # Subscriber code (Office id & sequential number) => OOOO-NNNNNNN
    subscriber_code.blank? ? "" : subscriber_code[0..3] + '-' + subscriber_code[4..10]
  end

  #
  # Records navigator
  #
  def to_first
    Subscriber.order("subscriber_code").first
  end

  def to_prev
    Subscriber.where("subscriber_code < ?", subscriber_code).order("subscriber_code").last
  end

  def to_next
    Subscriber.where("subscriber_code > ?", subscriber_code).order("subscriber_code").first
  end

  def to_last
    Subscriber.order("subscriber_code").last
  end

  searchable do
    text :subscriber_code, :first_name, :last_name, :company, :fiscal_id
    string :subscriber_code
    string :company
    string :last_name
    string :first_name
    string :fiscal_id
    integer :client_id
    integer :office_id
    integer :center_id
  end

  private

  # Before destroy
  def check_for_dependent_records
  end
end
