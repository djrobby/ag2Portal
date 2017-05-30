class CurrencyInstrument < ActiveRecord::Base
  belongs_to :currency
  attr_accessible :type_i, :value, :currency_id

  has_many :cash_desk_closing_instruments

  has_paper_trail

  validates :currency,  :presence => true
  validates :type_i,    :presence => true,
                        :length => { :is => 1 }
  validates :value,     :presence => true,
                        :uniqueness => { :scope => [:currency_id, :type_i] }

  # Callbacks
  before_destroy :check_for_dependent_records

  private

  def check_for_dependent_records
    # Check for cash desk closing instruments
    if cash_desk_closing_instruments.count > 0
      errors.add(:base, I18n.t('activerecord.models.currency_instrument.check_for_cash_desk_closings'))
      return false
    end
  end
end
