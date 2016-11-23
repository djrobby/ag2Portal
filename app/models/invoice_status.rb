class InvoiceStatus < ActiveRecord::Base
  # CONSTANTS
  PENDING = 1
  CASH = 2
  BANK = 3
  REFUND = 4
  FRACTIONATED = 5
  CHARGED = 99

  attr_accessible :name

  has_many :bills
  has_many :invoices

  has_paper_trail

  validates :name,  :presence => true

  #before_validation :fields_to_uppercase

  def fields_to_uppercase
    if !self.name.blank?
      self[:name].replace(self[:name].mb_chars.upcase!.to_s)
    end
  end

  def code
    case self.id
    when 1 then I18n.t('activerecord.attributes.invoice_status.code_1')
    when 2 then I18n.t('activerecord.attributes.invoice_status.code_2')
    when 3 then I18n.t('activerecord.attributes.invoice_status.code_3')
    when 4 then I18n.t('activerecord.attributes.invoice_status.code_4')
    when 5 then I18n.t('activerecord.attributes.invoice_status.code_5')
    when 99 then I18n.t('activerecord.attributes.invoice_status.code_99')
    end
  end
end
