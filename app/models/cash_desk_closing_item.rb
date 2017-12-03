class CashDeskClosingItem < ActiveRecord::Base
  # CONSTANTS
  CHARGE = "C"  #(I)NFLOW type -> Client payments & Inflow cash movements
  PAYMENT = "P" #(O)UTFLOW type -> Supplier payments & Outflow cash movements

  belongs_to :cash_desk_closing
  belongs_to :client_payment
  belongs_to :supplier_payment
  belongs_to :cash_movement_type

  attr_accessible :amount, :type_i,
                  :cash_desk_closing_id, :client_payment_id,
                  :supplier_payment_id, :cash_movement_type_id

  def type_label
    case type_i
      when "C" then I18n.t('activerecord.attributes.cash_desk_closing_item.type_c')
      when "P" then I18n.t('activerecord.attributes.cash_desk_closing_item.type_p')
      else 'N/A'
    end
  end
end
