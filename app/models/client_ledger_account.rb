class ClientLedgerAccount < ActiveRecord::Base
  belongs_to :client
  belongs_to :ledger_account
  belongs_to :company
  attr_accessor :thing
  attr_accessible :client_id, :ledger_account_id, :company_id, :thing

  has_paper_trail

  validates :ledger_account,  :presence => true
end
