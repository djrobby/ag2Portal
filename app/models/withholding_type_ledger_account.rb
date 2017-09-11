class WithholdingTypeLedgerAccount < ActiveRecord::Base
  belongs_to :withholding_type
  belongs_to :ledger_account
  belongs_to :company
  attr_accessible :withholding_type_id, :ledger_account_id, :company_id
end
