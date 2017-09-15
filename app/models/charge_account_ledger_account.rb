class ChargeAccountLedgerAccount < ActiveRecord::Base
  belongs_to :charge_account
  belongs_to :ledger_account
  belongs_to :company
  attr_accessor :thing
  attr_accessible :charge_account_id, :ledger_account_id, :company_id, :thing

  has_paper_trail

  validates :ledger_account,  :presence => true

  def ledger_account_full
    ledger_account.blank? ? 'N/A' : ledger_account.full_name
  end

  def company_full
    company.blank? ? 'N/A' : company.full_name
  end
end
