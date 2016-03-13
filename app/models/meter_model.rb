class MeterModel < ActiveRecord::Base
  belongs_to :manufacturer
  belongs_to :meter_type
  attr_accessible :brand, :model, :manufacturer_id, :meter_type_id

  has_paper_trail

  validates :manufacturer,  :presence => true
  validates :meter_type,    :presence => true
  validates :brand,         :presence => true
  validates :model,         :presence => true

  has_many :meters
end
