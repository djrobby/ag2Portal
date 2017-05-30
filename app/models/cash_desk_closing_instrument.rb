class CashDeskClosingInstrument < ActiveRecord::Base
  belongs_to :cash_desk_closing
  belongs_to :currency_instrument

  attr_accessible :amount, :cash_desk_closing_id, :currency_instrument_id, :quantity

  validates :quantity,  :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
end
