class RegulationType < ActiveRecord::Base
  attr_accessible :description

  has_many :regulations

  validates :description, :presence => true

  before_validation :fields_to_uppercase

  def fields_to_uppercase
    if !self.description.blank?
      self[:description].upcase!
    end
  end
end
