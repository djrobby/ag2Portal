class InvoiceType < ActiveRecord::Base
  # CONSTANTS
  WATER = 1
  TCA = 2
  CONTRACT = 3
  COMMERCIAL = 4
  OTHER = 5

  attr_accessible :name

  has_many :invoices

  has_paper_trail

  validates :name,  :presence => true

  def code
    case self.id
    when 1 then I18n.t('activerecord.attributes.invoice_type.code_1')
    when 2 then I18n.t('activerecord.attributes.invoice_type.code_2')
    when 3 then I18n.t('activerecord.attributes.invoice_type.code_3')
    when 4 then I18n.t('activerecord.attributes.invoice_type.code_4')
    when 5 then I18n.t('activerecord.attributes.invoice_type.code_5')
    end
  end
end
