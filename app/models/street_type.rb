class StreetType < ActiveRecord::Base
  attr_accessible :street_type_code, :street_type_description

  validates :street_type_description, :presence => true
  validates :street_type_code,        :presence => true,
                                      :length => { :minimum => 2 },
                                      :uniqueness => true
  before_validation :street_type_code_to_uppercase

  has_many :companies
  def street_type_code_to_uppercase
    self[:street_type_code].upcase!
  end

  def to_label
    #"#{street_type_description.titleize} (#{street_type_code})"
    "#{street_type_code} (#{street_type_description.titleize})"
  end
end
