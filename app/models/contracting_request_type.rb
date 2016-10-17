class ContractingRequestType < ActiveRecord::Base
  # CONSTANTS
  SUPPLY = 1
  SUBROGATION = 2
  CONNECTION = 3
  CHANGE_OWNERSHIP = 4

  attr_accessible :description

  has_many :contracting_requests

  validates :description,  :presence => true

  before_validation :fields_to_uppercase

  def fields_to_uppercase
    if !self.description.blank?
      self[:description].replace(self[:description].mb_chars.upcase!.to_s)
    end
  end
end
