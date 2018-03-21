class Instalment < ActiveRecord::Base
  belongs_to :instalment_plan
  # belongs_to :bill
  # belongs_to :invoice
  attr_accessible :amount, :instalment, :payday_limit, :surcharge,
                  :created_by, :updated_by,
                  :instalment_plan_id#, :bill_id, :invoice_id

  has_one :client_payment
  has_many :instalment_invoices, dependent: :destroy
  has_many :bills, through: :instalment_invoices
  has_many :invoices, through: :instalment_invoices

  has_paper_trail

  # Scopes
  scope :by_plan, -> { order(:instalment_plan_id, :instalment) }
  #
  scope :with_these_ids, -> ids {
    includes(:instalment_invoices)
    .where(id: ids)
    .by_plan
  }

  # Callbacks
  before_destroy :check_for_dependent_records

  def instalment_no
    !instalment_plan.nil? ? instalment_plan.full_no : "00000000000-0000-0000000"
  end

  def partial_instalment_no
    !instalment_plan.nil? ? instalment_plan.full_no[12..23] : "0000-0000000"
  end

  def instalment_date
    !instalment_plan.nil? ? instalment_plan.instalment_date : nil
  end

  def client
    !instalment_plan.nil? ? instalment_plan.client : nil
  end

  #
  # Calculated fields
  #
  def total
    amount + surcharge
  end

  def amount_collected
    client_payment.blank? ? 0 : client_payment.amount
  end

  def surcharge_collected
    client_payment.blank? ? 0 : client_payment.surcharge
  end

  def amount_debt
    amount - amount_collected
  end

  def surcharge_debt
    surcharge - surcharge_collected
  end

  def debt
    amount_debt + surcharge_debt
  end

  private

  def check_for_dependent_records
    # Check for client payment
    if client_payment
      errors.add(:base, I18n.t('activerecord.models.instalment.check_for_client_payments'))
      return false
    end
  end
end
