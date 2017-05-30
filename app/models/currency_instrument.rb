class CurrencyInstrument < ActiveRecord::Base
  belongs_to :currency
  attr_accessible :type_i, :value_i, :currency_id

  has_many :cash_desk_closing_instruments

  has_paper_trail

  validates :currency,  :presence => true
  validates :type_i,    :presence => true,
                        :length => { :is => 1 },
                        :numericality => { :only_integer => true, :greater_than => 0, :less_than => 3 }
  validates :value_i,   :presence => true,
                        :numericality => { :greater_than_or_equal_to => 0 },
                        :uniqueness => { :scope => [:currency_id, :type_i] }

  # Scopes
  scope :by_value, -> { order(type_i: :desc, value_i: :asc) }

  # Callbacks
  before_destroy :check_for_dependent_records

  def to_label
    "#{currency_code} #{type_label} #{value_label}"
  end

  def short_label
    "#{type_label} #{value_label}"
  end

  def currency_code
    currency.blank? ? "" : currency.alphabetic_code
  end

  def type_label
    case type_i
      when 1 then I18n.t('activerecord.attributes.currency_instrument.type_1')
      when 2 then I18n.t('activerecord.attributes.currency_instrument.type_2')
      else 'N/A'
    end
  end

  def value_label
    value_i.blank? ? "" : value_i.to_s
  end

  private

  def check_for_dependent_records
    # Check for cash desk closing instruments
    if cash_desk_closing_instruments.count > 0
      errors.add(:base, I18n.t('activerecord.models.currency_instrument.check_for_cash_desk_closings'))
      return false
    end
  end
end
