class ContractingRequestStatus < ActiveRecord::Base
  # CONSTANTS
  INITIAL = 1
  INSPECTION = 2
  BILLING = 3
  INSTALLATION = 10
  COMPLETE = 11

  attr_accessible :name, :requires_work_order, :id

  has_many :contracting_requests

  has_paper_trail

  validates :name,  :presence => true

  #before_validation :fields_to_uppercase

  def fields_to_uppercase
    if !self.name.blank?
      self[:name].replace(self[:name].mb_chars.upcase!.to_s)
    end
  end
end
