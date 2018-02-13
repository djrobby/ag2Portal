class InvoiceOperation < ActiveRecord::Base
  # CONSTANTS
  INVOICE = 1
  CANCELATION = 2
  REINVOICE = 3
  PAYMENT = 4

  attr_accessible :name

  has_many :invoices
  has_many :cancelled_invoices
  has_many :active_invoices
  has_many :active_supply_invoices

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
    when 1 then I18n.t('activerecord.attributes.invoice_operation.code_1')
    when 2 then I18n.t('activerecord.attributes.invoice_operation.code_2')
    when 3 then I18n.t('activerecord.attributes.invoice_operation.code_3')
    when 4 then I18n.t('activerecord.attributes.invoice_operation.code_4')
    end
  end

  def self.code_with_param(p)
    case p
    when 1 then I18n.t('activerecord.attributes.invoice_operation.code_1')
    when 2 then I18n.t('activerecord.attributes.invoice_operation.code_2')
    when 3 then I18n.t('activerecord.attributes.invoice_operation.code_3')
    when 4 then I18n.t('activerecord.attributes.invoice_operation.code_4')
    end
  end
end
