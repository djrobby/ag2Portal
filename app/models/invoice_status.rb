class InvoiceStatus < ActiveRecord::Base
  # CONSTANTS
  PENDING = 1
  CASH = 2
  BANK = 3
  REFUND = 4
  FRACTIONATED = 5
  CHARGED = 99

  attr_accessible :name

  has_many :bills
  has_many :invoices

  validates :name,  :presence => true

  before_validation :fields_to_uppercase

  def fields_to_uppercase
    if !self.name.blank?
      self[:name].replace(self[:name].mb_chars.upcase!.to_s)
    end
  end

end
