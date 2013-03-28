class StreetType < ActiveRecord::Base
  attr_accessible :street_type_code, :street_type_description

  validates :street_type_description, :presence => true
  validates :street_type_code,        :presence => true,
                                      :length => { :minimum => 2 }
end
