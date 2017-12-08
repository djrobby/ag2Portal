class CashMovement < ActiveRecord::Base
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

  # Methods
  def cash_movement_type_full_name
    cash_movement_type.full_name unless cash_movement_type.blank?
  end

  def cash_movement_type_code
    cash_movement_type.code unless cash_movement_type.blank?
  end

  def cash_movement_type_full_type_label
    cash_movement_type.type_label unless cash_movement_type.blank?
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

  private

  # Before destroy
  def check_for_dependent_records
    # Check for cash movements
    if cash_desk_closing_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.cash_movement_type.check_for_cash_desk_closing_items'))
      return false
    end
  end
end
