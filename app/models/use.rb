class Use < ActiveRecord::Base
  attr_accessible :code, :name

  has_many :water_supply_contracts
  has_many :subscribers
  has_many :tariff_schemes

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
    "#{code} #{name}"
  end

  def right_name
    name.blank? ? '' : name
  end

  private

  def fields_to_uppercase
    if !self.code.blank?
      self[:code].upcase!
    end
  end

  def check_for_dependent_records
    # Check for water supply contracts
    if water_supply_contracts.count > 0
      errors.add(:base, I18n.t('activerecord.models.use.water_supply_contracts'))
      return false
    end
    # Check for subscribers
    if subscribers.count > 0
      errors.add(:base, I18n.t('activerecord.models.use.subscribers'))
      return false
    end
  end
end
