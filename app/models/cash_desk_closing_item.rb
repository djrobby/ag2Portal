class CashDeskClosingItem < ActiveRecord::Base
  # CONSTANTS
  CHARGE = "C"  #(I)NFLOW type -> Client payments & Inflow cash movements
  PAYMENT = "P" #(O)UTFLOW type -> Supplier payments & Outflow cash movements
  NA = 0        # Not available
  CP = 1        # Client payment
  SP = 2        # Supplier payment
  OM = 3        # Other movement

  belongs_to :cash_desk_closing
  belongs_to :client_payment
  belongs_to :supplier_payment
  belongs_to :cash_movement
  belongs_to :payment_method

  attr_accessible :amount, :type_i,
                  :cash_desk_closing_id, :client_payment_id,
                  :supplier_payment_id, :cash_movement_id, :payment_method_id

  def type_label
    case type_i
      when "C" then I18n.t('activerecord.attributes.cash_desk_closing_item.type_c')
      when "P" then I18n.t('activerecord.attributes.cash_desk_closing_item.type_p')
      else 'N/A'
    end
  end

  def origin
    if !client_payment_id.blank?
      1
    elsif !supplier_payment_id.blank?
      2
    elsif !cash_movement_id.blank?
      3
    else
      0
    end
  end

  def origin_label
    case origin
      when 1 then I18n.t('activerecord.attributes.cash_desk_closing_item.origin_cp') + ' ' + client_payment.try(:invoice).try(:full_no)
      when 2 then I18n.t('activerecord.attributes.cash_desk_closing_item.origin_sp') + ' ' + supplier_payment.try(:supplier_invoice).try(:valid_number)
      when 3 then cash_movement.try(:cash_movement_type).try(:code)
      else 'N/A'
    end
  end
end
