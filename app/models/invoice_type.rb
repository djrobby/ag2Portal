class InvoiceType < ActiveRecord::Base
  # CONSTANTS
  WATER = 1
  TCA = 2
  CONTRACT = 3
  COMMERCIAL = 4
  OTHER = 5

  attr_accessible :name

  has_many :invoices
  has_many :cancelled_invoices
  has_many :active_invoices
  has_many :active_supply_invoices
  has_many :invoice_bills
  has_many :invoice_credits
  has_many :invoice_rebills

  has_paper_trail

  validates :name,  :presence => true

  # Scopes
  scope :commercial, -> { where("id != 1 AND id != 3") }

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
