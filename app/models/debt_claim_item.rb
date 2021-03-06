class DebtClaimItem < ActiveRecord::Base
  include ModelsModule

  belongs_to :debt_claim, :counter_cache => true
  belongs_to :bill
  belongs_to :invoice
  belongs_to :debt_claim_status
  # delegate :invoice_current_debt, :to => :invoice, :allow_nil => true
  attr_accessible :debt, :payday_limit, :created_by,
                  :debt_claim_id, :bill_id, :invoice_id, :debt_claim_status_id

  has_one :invoice_current_debt, through: :invoice

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
  before_destroy :update_debt_claim_totals

  #
  # Instance methods
  #
  def bill_no
    bill.bill_no unless (bill.blank? || bill.bill_no.blank?)
  end
  def bill_full_no
    (bill.blank? || bill.bill_no.blank?) ? '' : bill.full_no
  end

  def invoice_no
    invoice.invoice_no unless (invoice.blank? || invoice.invoice_no.blank?)
  end
  def invoice_full_no
    (invoice.blank? || invoice.invoice_no.blank?) ? '' : invoice.full_no
  end

  def project
    bill.project unless (bill.blank? || bill.project.blank?)
  end

  def client
    bill.client unless (bill.blank? || bill.client.blank?)
  end

  def subscriber
    bill.subscriber unless (bill.blank? || bill.subscriber.blank?)
  end

  def client_code_and_name
    (bill.blank? || bill.client.blank?) ? '' : bill.client.full_name_or_company_and_code
  end

  def subscriber_code_and_name
    (bill.blank? || bill.subscriber.blank?) ? '' : bill.subscriber.full_name_or_company_and_code
  end

  def formatted_payday_limit
    formatted_date(payday_limit) rescue ''
  end

  def status_name
    debt_claim_status.blank? ? '' : debt_claim_status.name
  end

  #
  # Calculated fields
  #
  # Based on cache values
  def surcharge
    debt * debt_claim.surcharge_pct
  end

  def total
    debt + surcharge
  end

  # Based on current values
  def current_debt
    invoice.debt
  end

  def current_surcharge
    current_debt * debt_claim.surcharge_pct
  end

  def current_total
    current_debt + current_surcharge
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
    self.debt_claim_status_id = DebtClaimStatus::INITIATED if debt_claim_status_id.blank?
  end

  def update_debt_claim_totals
    debt_claim.totals -= total if (!debt_claim.totals.blank? && debt_claim.totals > 0)
    debt_claim.subtotals -= debt if (!debt_claim.subtotals.blank? && debt_claim.subtotals > 0)
    debt_claim.surcharges -= surcharge if (!debt_claim.surcharges.blank? && debt_claim.surcharges > 0)
    debt_claim.save!
  end
end
