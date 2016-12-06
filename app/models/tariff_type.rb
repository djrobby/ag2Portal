class TariffType < ActiveRecord::Base
  attr_accessible :code, :name

  #has_many :tariff_schemes
  has_many :tariffs

  has_paper_trail

  validates :name, :presence => true
  validates :code, :presence => true,
                   :length => { :is => 3 },
                   :uniqueness => true

  # Scopes
  scope :by_code, -> { order(:code) }

  before_destroy :check_for_dependent_records
  before_validation :fields_to_uppercase

  def to_label
    "#{name} (#{code})"
  end

  private

  def fields_to_uppercase
    if !self.code.blank?
      self[:code].upcase!
    end
  end

  # Before destroy
  def check_for_dependent_records
    # Check for tariffs
    if tariffs.count > 0
      errors.add(:base, I18n.t('activerecord.models.tariff.check_for_tariffs'))
      return false
    end
  end
end
