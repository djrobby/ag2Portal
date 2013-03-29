class Zipcode < ActiveRecord::Base
  belongs_to :town
  belongs_to :province
  attr_accessible :zipcode, :town_id, :province_id

  validates :zipcode,  :presence => true
  validates :town_id,  :presence => true
  validates :province_id,  :presence => true

  has_many :companies
  def to_label
    "#{zipcode} - #{town.name} (#{province.name})"
  end
end
