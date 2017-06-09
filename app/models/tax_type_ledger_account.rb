class TaxTypeLedgerAccount < ActiveRecord::Base
  belongs_to :tax_type
  belongs_to :input_ledger_account, class_name: 'TaxType'
  belongs_to :output_ledger_account, class_name: 'TaxType'

  attr_accessor :thing
  attr_accessible :tax_type_id, :input_ledger_account_id, :output_ledger_account_id, :thing

  has_paper_trail

  validates :input_ledger_account,  :presence => true
  validates :output_ledger_account, :presence => true
end
