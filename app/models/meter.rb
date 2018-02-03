class Meter < ActiveRecord::Base
  include ModelsModule

  belongs_to :meter_model
  belongs_to :caliber
  belongs_to :meter_owner
  belongs_to :organization
  belongs_to :company
  belongs_to :office
  attr_accessible :expiry_date, :first_installation_date, :last_withdrawal_date, :manufacturing_date, :manufacturing_year,
                  :meter_code, :purchase_date,
                  :meter_model_id, :caliber_id, :meter_owner_id, :organization_id, :company_id, :office_id,
                  :created_by, :updated_by, :master_meter_id

  has_many :meter_details, dependent: :destroy
  has_many :work_orders
  has_many :readings
  has_many :subscribers
  has_many :service_points

  # Self join
  has_many :child_meters, class_name: 'Meter', foreign_key: 'master_meter_id'
  belongs_to :master_meter, class_name: 'Meter'

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
  # generic where (eg. for Select2 from engines_controller)
  scope :g_where, -> w {
    includes([meter_model: :meter_brand], :caliber)
    .where(w)
    .by_code
  }
  scope :g_where_with_subscribers, -> w {
    includes([meter_model: :meter_brand], :caliber, :subscribers)
    .where(w)
    .by_code
  }
  # Masters & Childs
  scope :master_meters,
    joins(:child_meters)
    .select("meters.*")
    .group("meters.meter_code")
    .having("count(child_meters_meters.id) > 0")
  # *******************
  # * Readable meters *
  # *******************
  # *** By service points ***
  # Return all rows, including duplicate meters
  scope :readable_service_point_meters_by_routes, -> r {
    joins(:service_points)
    .where("service_points.reading_route_id IN (?)", r)
    .order('service_points.reading_route_id, service_points.reading_sequence, service_points.reading_variant, meters.id')
  }
  scope :readable_service_point_meters_by_centers, -> c {
    joins(:service_points)
    .where("service_points.center_id IN (?)", c)
    .order('service_points.reading_route_id, service_points.reading_sequence, service_points.reading_variant, meters.id')
  }
  scope :readable_service_point_meters_by_centers_and_routes, -> c, r {
    joins(:service_points)
    .where("service_points.center_id IN (?) AND service_points.reading_route_id IN (?)", c, r)
    .order('service_points.reading_route_id, service_points.reading_sequence, service_points.reading_variant, meters.id')
  }
  # Return only one distinct row per meter, no duplicates
  scope :distinct_readable_service_point_meters_by_routes, -> r {
    readable_service_point_meters_by_routes(r).uniq
  }
  scope :distinct_readable_service_point_meters_by_centers, -> c {
    readable_service_point_meters_by_centers(c).uniq
  }
  scope :distinct_readable_service_point_meters_by_centers_and_routes, -> c, r {
    readable_service_point_meters_by_centers_and_routes(c, r).uniq
  }
  # *** By subscribers ***
  # Return all rows, including duplicate meters
  scope :active_subscribers, -> {
    joins(:subscribers)
    .where("(subscribers.ending_at IS NULL OR subscribers.ending_at >= ?) AND subscribers.active = true", Date.today)
  }
  scope :readable_subscriber_meters_by_routes, -> r {
    active_subscribers
    .where("subscribers.reading_route_id IN (?)", r)
    .order('subscribers.reading_route_id, subscribers.reading_sequence, subscribers.reading_variant, meters.id')
  }
  scope :readable_subscriber_meters_by_centers, -> c {
    active_subscribers
    .where("subscribers.center_id IN (?)", c)
    .order('subscribers.reading_route_id, subscribers.reading_sequence, subscribers.reading_variant, meters.id')
  }
  scope :readable_subscriber_meters_by_centers_and_routes, -> c, r {
    active_subscribers
    .where("subscribers.center_id IN (?) AND subscribers.reading_route_id IN (?)", c, r)
    .order('subscribers.reading_route_id, subscribers.reading_sequence, subscribers.reading_variant, meters.id')
  }
  # Return only one distinct row per meter, no duplicates
  scope :distinct_readable_subscriber_meters_by_routes, -> r {
    readable_subscriber_meters_by_routes(r).uniq
  }
  scope :distinct_readable_subscriber_meters_by_centers, -> c {
    readable_subscriber_meters_by_centers(c).uniq
  }
  scope :distinct_readable_subscriber_meters_by_centers_and_routes, -> c, r {
    readable_subscriber_meters_by_centers_and_routes(c, r).uniq
  }

  # Callbacks
  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records

  # Methods
  def to_label
    "#{full_name}"
  end

  def fields_to_uppercase
    if !self.meter_code.blank?
      self[:meter_code].upcase!
    end
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

  # Current meter coding from 2010:
  # Length must be 12 chars
  # Format: BYYMCSSSSSSK (FAAMC000000K)
  # B       ->  Manufacturer (brand) Id (meter_brand.letter_id)
  # YY      ->  Manufacturing year
  # M       ->  Model Id (meter_model.letter_id)
  # C       ->  Caliber Id (caliber.letter_id)
  # SSSSSS  ->  Serial number
  # K       ->  Control digit
  # Returns:
  # $err            ->  meter_code do not validate (<12 or bad format)
  # $manufacturer   ->  manufacturer invalid
  # $year           ->  year invalid
  # $model          ->  model invalid
  # $caliber        ->  caliber invalid
  # $serial         ->  serial no. invalid
  # $control$       ->  control digit invalid (returns obtained digit)
  # $ok             ->  no errors detected: OK
  def check_meter_code
    ret = '$err'
    if !meter_code.blank? && meter_code.length == 12
      b = meter_code[0]
      yy = meter_code[1..2]
      m = meter_code[3]
      c = meter_code[4]
      ssssss = meter_code[5..10]
      k = meter_code[11]
      manufacturer_letter = meter_model.meter_brand.letter_id rescue nil
      model_letter = meter_model.letter_id rescue nil
      caliber_letter = caliber.letter_id rescue nil
      st2 = (11 * (meter_code[0].ord - "A".ord)) + (8 * (meter_code[3].ord - "A".ord)) + (7 * (meter_code[4].ord - "A".ord))
      st1 = (10 * meter_code[1].to_i) + (9 * meter_code[2].to_i) + (6 * meter_code[5].to_i) + (5 * meter_code[6].to_i) +
            (4 * meter_code[7].to_i) + (3 * meter_code[8].to_i) + (2 * meter_code[9].to_i) + meter_code[10].to_i
      control_digit = ("A".ord + ((st1 + st2) % 26)).chr
      # Check manufacturer
      if !manufacturer_letter.blank? && manufacturer_letter == b
        # Check year
        if is_numeric?(yy)
          # Check model
          if !model_letter.blank? && model_letter == m
            # Check caliber
            if !caliber_letter.blank? && caliber_letter == c
              # Check serial no.
              if is_numeric?(ssssss)
                # Check control digit
                if !control_digit.blank? && control_digit == k
                  ret = '$ok'
                else
                  ret = '$control$' + control_digit
                end
              else
                ret = '$serial'
              end
            else
              ret = '$caliber'
            end
          else
            ret = '$model'
          end
        else
          ret = '$year'
        end
      else
        ret = '$manufacturer'
      end
    end
    ret
  end

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

  def order_sequence
    if subscribers.first.blank?
      0
    else
      subscribers.first.reading_sequence
    end
  end

  def model_brand_caliber
    full_name = ""
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
  def assigned_to_service_point?
    !service_points.empty?
  end

  # Shared meter
  def shared_coefficient
    subscribers.size
  end
  def is_shared?
    shared_coefficient > 1
  end

  def active_detail
    meter_details.where(withdrawal_date: nil).order(:installation_date).last
  end

  def current_location
    active_detail.meter_location rescue nil
  end

  # Have child meters? (Is master?)
  def child_meters_count
    child_meters.size
  end
  def have_child_meters?
    child_meters.size > 0
  end
  def is_master?
    have_child_meters?
  end
  def is_child?
    !master_meter_id.nil? && master_meter_id > 0
  end
  # Users
  def users
    child_meters.joins(:subscribers).where("(subscribers.ending_at IS NULL OR subscribers.ending_at >= ?) AND subscribers.active = true", Date.today).size
  end
  # Individual or Collective?
  def individual_or_collective
    users > 0 ? 'C' : 'I'
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
    if subscribers.count > 0
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
