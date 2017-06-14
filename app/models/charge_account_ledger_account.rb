class ChargeAccountLedgerAccount < ActiveRecord::Base
  belongs_to :charge_account
  belongs_to :ledger_account
  belongs_to :company
  attr_accessor :thing
  attr_accessible :charge_account_id, :ledger_account_id, :company_id, :thing

  has_paper_trail

  validates :ledger_account,  :presence => true
end
