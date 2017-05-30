class CashDeskClosingItem < ActiveRecord::Base
  belongs_to :cash_desk_closing
  belongs_to :client_payment
  belongs_to :supplier_payment

  attr_accessible :amount, :type_i,
                  :cash_desk_closing_id, :client_payment_id, :supplier_payment_id
end
