class SepaReturnCode < ActiveRecord::Base
  attr_accessible :code, :name

  has_many :client_payments

  has_paper_trail

  validates :code,  :presence => true,
                    :length => { :minimum => 4, :maximum => 10 }
  validates :name,  :presence => true

  # Scopes
  scope :by_code, -> { order(:code) }

  # Callbacks
  before_validation :fields_to_uppercase

  def fields_to_uppercase
    if !self.code.blank?
      self[:code].upcase!
    end
    true
  end
end
