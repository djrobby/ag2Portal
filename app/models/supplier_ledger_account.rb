class SupplierLedgerAccount < ActiveRecord::Base
  belongs_to :supplier
  belongs_to :ledger_account
  belongs_to :company
  attr_accessor :thing
  attr_accessible :supplier_id, :ledger_account_id, :company_id, :thing

  has_paper_trail

  validates :ledger_account,  :presence => true
end
