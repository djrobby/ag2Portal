class StreetDirectory < ActiveRecord::Base
  belongs_to :town
  belongs_to :street_type
  belongs_to :zipcode
  attr_accessible :street_name, :town_id, :street_type_id, :zipcode_id

  has_many :service_points

  validates :town,        :presence => true
  validates :street_type, :presence => true
  validates :street_name, :presence => true

  # Scopes
  scope :by_towns, ->(town_ids) { where(town_id: town_ids) }

  def to_label
    "#{street_type.street_type_code} #{street_name}"
  end

  def to_full_label
    "#{street_type.street_type_code} #{street_name} (#{town.name})"
  end
end
