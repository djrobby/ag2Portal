class Currency < ActiveRecord::Base
  attr_accessible :alphabetic_code, :currency, :minor_unit, :numeric_code

  has_many :countries
  has_many :currency_instruments

  has_paper_trail

  validates :currency,        :presence => true
  validates :alphabetic_code, :presence => true,
                              :length => { :is => 3 },
                              :uniqueness => true
  validates :numeric_code,    :presence => true,
                              :length => { :is => 3 },
                              :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 },
                              :uniqueness => true
  validates :minor_unit,      :length => { :is => 1 },
                              :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }

  # Scopes
  scope :by_code, -> { order(:alphabetic_code) }
  #
  scope :having_code, -> c { where(alphabetic_code: c).by_code }

  # Callbacks
  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records

  def fields_to_uppercase
    if !self.alphabetic_code.blank?
      self[:alphabetic_code].upcase!
    end
  end

  def to_label
    "#{alphabetic_code} #{currency}"
  end

  private

  def check_for_dependent_records
    # Check for countries
    if countries.count > 0
      errors.add(:base, I18n.t('activerecord.models.currency.check_for_countries'))
      return false
    end
  end
end
