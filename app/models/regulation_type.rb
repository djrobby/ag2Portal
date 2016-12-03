class RegulationType < ActiveRecord::Base
  attr_accessible :description

  has_many :regulations

  has_paper_trail

  validates :description, :presence => true

  before_validation :fields_to_uppercase

  def to_label
    "#{description}"
  end

  private

  def fields_to_uppercase
    if !self.description.blank?
      self[:description].upcase!
    end
  end
end
