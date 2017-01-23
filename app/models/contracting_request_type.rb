class ContractingRequestType < ActiveRecord::Base
  # CONSTANTS
  SUPPLY = 1
  SUBROGATION = 2
  CONNECTION = 3
  CHANGE_OWNERSHIP = 4

  attr_accessible :description

  has_many :contracting_requests

  has_paper_trail

  validates :description,  :presence => true

  #before_validation :fields_to_uppercase

  def fields_to_uppercase
    if !self.description.blank?
      self[:description].upcase!
    end
  end
end
