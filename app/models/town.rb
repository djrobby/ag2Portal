class Town < ActiveRecord::Base
  belongs_to :province
  attr_accessible :ine_cmun, :ine_dc, :name, :province_id

  validates :name,  :presence => true
  validates :province_id,  :presence => true
  validates :ine_cmun, :length => { :minimum => 3 }
  validates :ine_dc, :length => { :minimum => 1 }

  has_many :towns
  has_many :companies
  has_many :zipcodes
  def to_label
    "#{name} (#{province.name})"
  end
end
