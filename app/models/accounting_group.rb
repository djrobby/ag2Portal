class AccountingGroup < ActiveRecord::Base
  attr_accessible :code, :name
  has_many :ledger_accounts

  has_paper_trail

  validates :code,  :presence => true,
                    :length => { :is => 1 },
                    :format => { with: /\A\d+\Z/, message: :code_invalid },
                    :uniqueness => true
  validates :name,  :presence => true
  
  before_destroy :check_for_ledger_accounts

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = code.blank? ? "" : code.strip
    if !self.name.blank?
      full_name += " " + self.name[0,40]
    end
    full_name
  end

  private
  
  def check_for_ledger_accounts
    if ledger_accounts.count > 0
      errors.add(:base, I18n.t('activerecord.models.accounting_group.check_for_ledger_accounts'))
      return false
    end
  end
end
