class StreetDirectory < ActiveRecord::Base
  belongs_to :town
  belongs_to :street_type
  belongs_to :zipcode
  attr_accessible :street_name, :town_id, :street_type_id, :zipcode_id, :alt_code

  has_many :service_points
  has_many :subscribers

  has_paper_trail

  validates :town,        :presence => true
  validates :street_type, :presence => true
  validates :street_name, :presence => true,
                          :uniqueness => { scope: [:street_type_id, :town_id] }

  # Scopes
  scope :by_name_type, -> { order('street_directories.street_name, street_directories.street_type_id') }
  #
  scope :by_towns, ->(town_ids) { where(town_id: town_ids).by_name_type }
  scope :for_dropdown_by_town, -> town {
    joins(:street_type)
    .select("street_directories.id,
             CONCAT(CASE WHEN ISNULL(street_directories.alt_code) THEN '' ELSE CONCAT(street_directories.alt_code, ' - ') END, street_types.street_type_code, ' ', street_directories.street_name) to_label_")
    .where(town_id: town)
    .by_name_type
  }
  scope :for_dropdown, -> {
    joins(:street_type)
    .select("street_directories.id,
             CONCAT(CASE WHEN ISNULL(street_directories.alt_code) THEN '' ELSE CONCAT(street_directories.alt_code, ' - ') END, street_types.street_type_code, ' ', street_directories.street_name) to_label_")
    .by_name_type
  }

  # Callbacks
  before_save :upcase_street_name

  # Methods
  def to_label
    if alt_code.blank?
      "#{street_type.street_type_code} #{street_name}"
    else
      "#{alt_code} - #{street_type.street_type_code} #{street_name}"
    end
  end

  def to_full_label
    if alt_code.blank?
      "#{street_type.street_type_code} #{street_name} (#{town.name})"
    else
      "#{alt_code} - #{street_type.street_type_code} #{street_name} (#{town.name})"
    end
  end

  def town_name
    town.name
  end

  #
  # Class (self) user defined methods
  #
  def self.dropdown(town=nil)
    if town.present?
      self.for_dropdown_by_town(town)
    else
      self.for_dropdown
    end
  end

  searchable do
    text :street_name, :town_name, :alt_code
    string :street_name
    integer :town_id
    integer :street_type_id
    integer :zipcode_id
    string :alt_code
  end

  private

  def upcase_street_name
    self.street_name = street_name.try(:upcase)
  end
end
