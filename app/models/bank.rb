class Bank < ActiveRecord::Base
  attr_accessible :code, :name, :swift

  has_many :supplier_bank_accounts

  has_paper_trail

  validates :code,  :presence => true,
                    :length => { :is => 4 },
                    :format => { with: /\A\d+\Z/, message: :code_invalid },
                    :uniqueness => true
  validates :name,  :presence => true
  validates :swift, :length => { :minimum => 8, :maximum => 11 }, :if => "!swift.blank?"

  before_destroy :check_for_dependent_records

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = ""
    if !self.code.blank?
      full_name += self.code
    end
    if !self.name.blank?
      full_name += " " + self.name
    end
    full_name
  end

  private

  def check_for_dependent_records
    # Check for supplier bank accounts
    if supplier_bank_accounts.count > 0
      errors.add(:base, I18n.t('activerecord.models.bank.check_for_supplier_bank_accounts'))
      return false
    end
    # Check for client bank accounts
    if client_bank_accounts.count > 0
      errors.add(:base, I18n.t('activerecord.models.bank.check_for_client_bank_accounts'))
      return false
    end
  end
end
