class DebtClaimItem < ActiveRecord::Base
  belongs_to :debt_claim, :counter_cache => true
  belongs_to :bill
  belongs_to :invoice
  belongs_to :debt_claim_status
  attr_accessible :debt, :payday_limit,
                  :debt_claim_id, :bill_id, :invoice_id, :debt_claim_status_id

  has_paper_trail

  # Validations
  validates :bill,              :presence => true
  validates :invoice,           :presence => true
  validates :debt_claim_status, :presence => true

  # Scopes

  # Callbacks
  before_create :init_debt

  #
  # Instance methods
  #
  def bill_no
    bill.bill_no unless (bill.blank? || bill.bill_no.blank?)
  end

  def invoice_no
    invoice.invoice_no unless (invoice.blank? || invoice.invoice_no.blank?)
  end

  def project
    debt_claim.project unless (debt_claim.blank? || debt_claim.project.blank?)
  end

  def client
    bill.client unless (bill.blank? || bill.client.blank?)
  end

  def subscriber
    bill.subscriber unless (bill.blank? || bill.subscriber.blank?)
  end

  #
  # Calculated fields
  #
  def current_debt
    invoice.debt
  end

  def surcharge
    debt * debt_claim.surcharge_pct
  end

  def total
    debt + surcharge
  end

  def current_total
    current_debt + surcharge
  end

  #
  # Class (self) user defined methods
  #

  #
  # Search
  #

  private

  # Before create
  def init_debt
    self.debt = current_debt
    self.debt_claim_status_id = DebtClaimStatus.first.id if debt_claim_status_id.blank?
  end
end
