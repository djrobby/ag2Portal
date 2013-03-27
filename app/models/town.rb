class Town < ActiveRecord::Base
  belongs_to :province
  attr_accessible :ine_cmun, :ine_dc, :name, :province_id

  validates :name,  :presence => true
  validates :province_id,  :presence => true
  validates :ine_cmun, :presence => true,
                       :length => { :minimum => 3 }
  validates :ine_dc, :presence => true,
                       :length => { :minimum => 1 }
end
