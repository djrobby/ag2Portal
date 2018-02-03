class ServicePoint < ActiveRecord::Base
  belongs_to :service_point_type
  belongs_to :service_point_location
  belongs_to :service_point_purpose
  belongs_to :water_connection
  belongs_to :organization
  belongs_to :company
  belongs_to :office
  belongs_to :center
  belongs_to :street_directory
  belongs_to :zipcode
  belongs_to :reading_route
  belongs_to :meter
  attr_accessible :available_for_contract, :building, :cadastral_reference, :code, :diameter, :floor, :floor_office,
                  :gis_id, :name, :street_number, :verified,
                  :service_point_type_id, :service_point_location_id, :service_point_purpose_id,
                  :water_connection_id, :organization_id, :company_id, :office_id, :center_id,
                  :street_directory_id, :zipcode_id, :km,
                  :meter_id, :reading_route_id, :reading_sequence, :reading_variant

  has_paper_trail

  has_many :subscribers

  validates :code,                    :presence => true,
                                      :length => { :minimum => 3, :maximum => 11 }
  validates :service_point_type,      :presence => true
  validates :service_point_location,  :presence => true
  validates :service_point_purpose,   :presence => true
  validates :organization,            :presence => true
  validates :center,                  :presence => true
  validates :street_directory,        :presence => true

  # Scopes
  scope :by_code, -> { order(:code) }
  scope :by_reading_sequence, -> { order(:reading_route_id, :reading_sequence, :reading_variant, :code) }
  #
  scope :belongs_to_office, -> office { where("office_id = ?", office).by_code }
  # *** For readings ***
  scope :with_meter, -> { where("((NOT meter_id IS NULL) AND meter_id >= 0)").by_reading_sequence }
  scope :belongs_to_routes, -> r { where("reading_route_id IN (?)", r).by_reading_sequence }
  scope :belongs_to_routes_with_meter, -> r { belongs_to_routes(r).with_meter.by_reading_sequence }
  scope :belongs_to_centers, -> c { where("center_id IN (?)", c).by_reading_sequence }
  scope :belongs_to_centers_with_meter, -> c { belongs_to_centers(c).with_meter.by_reading_sequence }
  scope :belongs_to_centers_and_routes_with_meter, -> c, r {
    belongs_to_centers(c).belongs_to_routes(r).with_meter.by_reading_sequence
  }

  def to_label
    _ret = code
    if street_directory.nil?
      _ret = _ret + " " + I18n.t("activerecord.models.service_point.no_street_directory_error") + " (id:#{id})"
    else
      _ret = _ret + " " + address_1
    end
    _ret
  end

  def to_full_label
    if street_directory.nil?
      I18n.t("activerecord.models.service_point.no_street_directory_error") + " (id:#{id})"
    else
      "#{street_directory.street_type.street_type_code} #{street_directory.street_name}, #{street_number} #{floor} #{floor_office}, (#{street_directory.town.name})"
    end
  end

  def full_code
    # Subscriber code (Office id & sequential number) => OOOO-NNNNNNN
    code.blank? ? "" : code[0..3] + '-' + code[4..10]
  end

  def full_address
    address_1 + " - " + address_2
  end

  def address_1
    _ret = ""
    if !street_directory.blank?
      if !street_directory.street_type.blank?
        _ret += street_directory.street_type.street_type_code.titleize + ". "
      end
      if !street_directory.street_name.blank?
        _ret += street_directory.street_name + " "
      end
      if !street_number.blank?
        _ret += street_number
      end
      if !building.blank?
        _ret += ", " + building.titleize
      end
      if !floor.blank?
        _ret += ", " + floor_human
      end
      if !floor_office.blank?
        _ret += " " + floor_office
      end
    end
    _ret
  end

  def address_2
    _ret = ""
    if !zipcode.blank?
      _ret += zipcode.zipcode + " "
      if !zipcode.town.blank?
        _ret += zipcode.town.name + ", "
      end
      if !zipcode.province.blank?
        _ret += zipcode.province.name + " "
        if !zipcode.province.region.country.blank?
          _ret += "(" + zipcode.province.region.country.name + ")"
        end
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

  def assigned_to_subscriber?
    !subscribers.empty?
  end

  def to_label_and_assigned
    to_label + (assigned_to_subscriber? ? '*' : '')
  end

  # Searchable attributes
  searchable do
    text :code
    string :service_address do
      street_directory.street_name
    end
    text :service_point_full_address do
      full_address
    end
    integer :id
    string :code
    boolean :available_for_contract
    boolean :assigned_to_subscriber do
      assigned_to_subscriber?
    end
    integer :office_id
    integer :service_point_type_id
    integer :service_point_location_id
    integer :service_point_purpose_id
    integer :street_directory_id
    integer :zipcode_id
    integer :reading_route_id
    integer :organization_id
  end
end
