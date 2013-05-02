class Region < ActiveRecord::Base
  belongs_to :country
  attr_accessible :country_id, :name

  validates :name,        :presence => true
  validates :country_id,  :presence => true

  has_many :provinces
  def to_label
    "#{name} (#{country.name})"
  end
end
