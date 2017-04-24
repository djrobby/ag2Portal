class SupplierLedgerAccount < ActiveRecord::Base
  belongs_to :supplier
  belongs_to :ledger_account
  attr_accessor :thing
  attr_accessible :supplier_id, :ledger_account_id, :thing

  has_paper_trail

  validates :ledger_account,  :presence => true
end
