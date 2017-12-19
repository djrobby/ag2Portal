class CashMovement < ActiveRecord::Base
  include ModelsModule

  belongs_to :cash_movement_type
  belongs_to :payment_method
  belongs_to :organization
  belongs_to :company
  belongs_to :office
  belongs_to :project
  belongs_to :charge_account
  attr_accessible :amount, :movement_date, :cash_movement_type_id, :payment_method_id,
                  :organization_id, :company_id, :office_id, :project_id, :charge_account_id

  has_many :cash_desk_closing_items

  has_paper_trail

  validates :cash_movement_type,  :presence => true
  validates :payment_method,      :presence => true
  validates :movement_date,       :presence => true
  validates :amount,              :presence => true,
                                  :numericality => true
  validates :organization,        :presence => true
  validates :company,             :presence => true

  # Scopes
  scope :by_no, -> { order('cash_movements.movement_date, cash_movements.id') }
  scope :by_payment, -> { order('cash_movements.payment_method_id, cash_movements.movement_date, cash_movements.id') }
  # Pending of Cash desk closing
  scope :no_cash_desk_closing_yet, -> w {
    joins(:payment_method)
    .joins('LEFT JOIN cash_desk_closing_items ON cash_movements.id=cash_desk_closing_items.cash_movement_id')
    .where(w)
    .where('cash_desk_closing_items.cash_movement_id IS NULL')
    .by_no
  }

  # Callbacks
  before_destroy :check_for_dependent_records
  before_save :check_for_amount # must store negative if cash_movement_type.type_id == CashMovementType.OUTFLOW

  # Methods
  def to_label
    "#{id.to_s} #{cash_movement_type_code}: #{formatted_amount}"
  end

  def cash_movement_type_full_name
    cash_movement_type.full_name unless cash_movement_type.blank?
  end

  def cash_movement_type_code
    cash_movement_type.right_code unless cash_movement_type.blank?
  end

  def cash_movement_type_full_type_label
    cash_movement_type.type_label unless cash_movement_type.blank?
  end

  def right_code_and_type_label
    cash_movement_type.right_code_and_type_label unless cash_movement_type.blank?
  end

  def cash_desk_closing_item_type_i
    cash_movement_type.cash_desk_closing_item_type_i unless cash_movement_type.blank?
  end

  def payment_method_description
    payment_method.description unless payment_method.blank?
  end

  def payment_method_flow_label
    payment_method.flow_label unless payment_method.blank?
  end

  def formatted_amount
    formatted_number(amount, 2)
  end

  def charge_account_description
    charge_account.full_name unless charge_account.blank?
  end

  def project_description
    project.full_name unless project.blank?
  end

  def office_description
    office.name unless office.blank?
  end

  def company_description
    company.name unless company.blank?
  end

  def organization_description
    organization.name unless organization.blank?
  end

  def used_in_cash_desk_closing
    cash_desk_closing_items.count > 0 rescue false
  end

  def ocop
    # Organization, Company, Office, Project
    _ocop = '000'
    if !organization_id.blank?
      _ocop = organization_id.to_s.rjust(3, '0')
    end
    if !company_id.blank?
      _ocop += '-' + company_id.to_s.rjust(3, '0')
    else
      _ocop += '-000'
    end
    if !office_id.blank?
      _ocop += '-' + office_id.to_s.rjust(3, '0')
    else
      _ocop += '-000'
    end
    if !project_id.blank?
      _ocop += '-' + project_id.to_s.rjust(3, '0')
    else
      _ocop += '-000'
    end
    _ocop
  end

  #
  # Class (self) user defined methods
  #
  # Payment method suitable to use
  def self.right_payment_methods(_organization=nil)
    if _organization.blank?
      PaymentMethod.used_by_cashier
    else
      PaymentMethod.used_by_cashier_and_organization(_organization)
    end
  end

  searchable do
    integer :id
    integer :office_id
    integer :company_id
    integer :organization_id
    integer :project_id
    integer :cash_movement_type_id
    integer :payment_method_id
    date :movement_date
    date :created_at
  end

  private

  # Before save
  def check_for_amount
    self.amount = self.amount * (-1) if (cash_movement_type.type_id == CashMovementType.OUTFLOW && self.amount > 0)
  end

  # Before destroy
  def check_for_dependent_records
    # Check for cash movements
    if cash_desk_closing_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.cash_movement_type.check_for_cash_desk_closing_items'))
      return false
    end
  end
end
