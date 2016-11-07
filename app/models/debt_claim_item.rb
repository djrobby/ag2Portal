class DebtClaimItem < ActiveRecord::Base
  belongs_to :debt_claim
  belongs_to :bill
  belongs_to :invoice
  belongs_to :debt_claim_status
  attr_accessible :payday_limit
end
