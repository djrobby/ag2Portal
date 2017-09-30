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
  scope :grouped_by_debt_claim, group(:debt_claim_id)
  scope :belongs_to_client, -> c { joins(:bill).group(:debt_claim_id).where(bills: { client_id: c }) }
  scope :has_status, -> s { group(:debt_claim_id).where(debt_claim_status_id: s) }
  scope :belongs_to_client_and_has_status, -> c, s {
    joins(:bill).group(:debt_claim_id).where(bills: { client_id: c }, debt_claim_status_id: s)
  }

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
  searchable do
    string :client_code_name_fiscal, :multiple => true do
      bill.client.full_name_or_company_code_fiscal unless (bill.blank? || bill.client.blank?)
    end
    string :subscriber_code_name_fiscal, :multiple => true do
      bill.subscriber.code_full_name_or_company_fiscal unless (bill.blank? || bill.subscriber.blank?)
    end
    string :supply_address, :multiple => true do
      bill.subscriber.subscriber_supply_address.supply_address unless (bill.subscriber.blank? || bill.subscriber.subscriber_supply_address.blank? || bill.subscriber.subscriber_supply_address.supply_address.blank?)
    end
    integer :client_id do
      bill.client_id unless (bill.blank? || bill.client_id.blank?)
    end
    integer :subscriber_id do
      bill.subscriber_id unless (bill.blank? || bill.subscriber_id.blank?)
    end
    integer :project_id, :multiple => true do
      debt_claim.project_id unless (debt_claim.blank? || debt_claim.project_id.blank?)
    end
    date :payday_limit
    integer :id
    integer :debt_claim_status_id
    integer :bill_id
    integer :invoice_id
  end

  private

  # Before create
  def init_debt
    self.debt = current_debt
    self.debt_claim_status_id = DebtClaimStatus.first.id if debt_claim_status_id.blank?
  end
end
