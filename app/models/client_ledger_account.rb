class ClientLedgerAccount < ActiveRecord::Base
  belongs_to :client
  belongs_to :ledger_account
  attr_accessor :thing
  attr_accessible :client_id, :ledger_account_id, :thing

  has_paper_trail

  validates :ledger_account,  :presence => true
end
