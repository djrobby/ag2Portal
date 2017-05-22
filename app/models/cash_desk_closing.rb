class CashDeskClosing < ActiveRecord::Base
  attr_accessible :amount_collected, :closing_balance, :invoices_collected, :opening_balance
end
