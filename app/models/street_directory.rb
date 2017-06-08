class StreetDirectory < ActiveRecord::Base
  belongs_to :town
  belongs_to :street_type
  belongs_to :zipcode
  attr_accessible :street_name, :town_id, :street_type_id, :zipcode_id

  has_many :service_points
  has_many :subscribers

  has_paper_trail

  validates :town,        :presence => true
  validates :street_type, :presence => true
  validates :street_name, :presence => true,
                          :uniqueness => { scope: [:street_type_id, :town_id] }

  before_save :upcase_street_name

  # Scopes
  scope :by_name_type, -> { order(:street_name, :street_type_id) }
  #
  scope :by_towns, ->(town_ids) { where(town_id: town_ids).by_name_type }

  def to_label
    "#{street_type.street_type_code} #{street_name}"
  end

  def to_full_label
    "#{street_type.street_type_code} #{street_name} (#{town.name})"
  end

  def town_name
    town.name
  end

  searchable do
    text :street_name, :town_name
    string :street_name
    integer :town_id
    integer :street_type_id
    integer :zipcode_id
  end

  private

  def upcase_street_name
    self.street_name = street_name.try(:upcase)
  end
end
