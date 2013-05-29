class StreetType < ActiveRecord::Base
  attr_accessible :street_type_code, :street_type_description,
                  :created_by, :updated_by

  has_paper_trail

  validates :street_type_description, :presence => true
  validates :street_type_code,        :presence => true,
                                      :length => { :minimum => 2 },
                                      :uniqueness => true
  before_validation :street_type_code_to_uppercase

  has_many :towns
  has_many :companies
  has_many :workers
  has_many :shared_contacts
  def street_type_code_to_uppercase
    self[:street_type_code].upcase!
  end

  def to_label
    "#{street_type_code} (#{street_type_description.titleize})"
  end
end
