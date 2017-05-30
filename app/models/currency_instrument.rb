class CurrencyInstrument < ActiveRecord::Base
  belongs_to :currency
  attr_accessible :type, :value
end
