class DebtClaim < ActiveRecord::Base
  belongs_to :project
  belongs_to :debt_claim_phase
  attr_accessible :claim_no, :closed_at
end
