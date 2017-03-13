class Project < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_projects
  belongs_to :organization
  belongs_to :company
  belongs_to :office
  belongs_to :project_type
  belongs_to :ledger_account
  attr_accessible :closed_at, :ledger_account_id, :name, :opened_at, :project_code,
                  :office_id, :company_id, :organization_id, :project_type_id,
                  :max_order_total, :max_order_price

  has_many :charge_accounts
  has_many :work_orders
  has_many :purchase_orders
  has_many :purchase_order_items
  has_many :receipt_notes
  has_many :receipt_note_items
  has_many :offer_requests
  has_many :offer_request_items
  has_many :offers
  has_many :offers_items
  has_many :supplier_invoices
  has_many :supplier_invoice_items
  has_many :delivery_notes
  has_many :delivery_note_items
  has_many :sale_offers
  has_many :sale_offer_items
  has_many :bills
  has_many :billing_periods
  has_many :billable_items
  has_many :pre_readings
  has_many :readings
  has_many :reading_routes
  has_many :tariff_shemes
  has_many :regulations
  has_many :contracting_requests

  has_paper_trail

  validates :name,          :presence => true
  validates :project_code,  :presence => true,
                            :length => { :is => 12 },
                            :format => { with: /\A[a-zA-Z\d]+\Z/, message: :code_invalid },
                            :uniqueness => { :scope => :organization_id }
  validates :opened_at,     :presence => true
  validates :company,       :presence => true
  validates :office,        :presence => true
  validates :organization,  :presence => true
  validates :project_type,  :presence => true

  # Scopes
  scope :by_code, -> { order(:project_code) }
  #
  scope :belongs_to_organization, -> organization { where("organization_id = ?", organization).by_code }
  scope :belongs_to_company, -> company { where("company_id = ?", company).by_code }
  scope :belongs_to_office, -> office { where("office_id = ?", office).by_code }
  scope :belongs_to_type, -> type { where("project_type_id = ?", type).by_code }

  before_destroy :check_for_dependent_records

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = full_code
    if !self.name.blank?
      full_name += " " + self.name[0,40]
    end
    full_name
  end

  def full_code
    # Project code (Company id & project type code & sequential number) => CCC-TTT-NNNNNN
    project_code.blank? ? "" : project_code[0..2] + '-' + project_code[3..5] + '-' + project_code[6..11]
  end

  #
  # Calculated fields
  #
  def active_yes_no
    closed_at.blank? ? I18n.t(:yes_on) : I18n.t(:no_off)
  end

  def has_analytical_plan?
    charge_accounts.size > 0 ? true : false
  end

  #
  # Class (self) user defined methods
  #
  def self.active_only
    where("closed_at IS NULL").order(:project_code)
  end

  #
  # Records navigator
  #
  def to_first
    Project.order("project_code").first
  end

  def to_prev
    Project.where("project_code < ?", id).order("project_code").last
  end

  def to_next
    Project.where("project_code > ?", id).order("project_code").first
  end

  def to_last
    Project.order("project_code").last
  end

  searchable do
    text :project_code, :name
    string :project_code, :multiple => true   # Multiple search values accepted in one search (inverse_no_search)
    integer :company_id
    integer :office_id
    integer :organization_id
    string :sort_no do
      project_code
    end
  end

  private

  def check_for_dependent_records
    # Check for charge accounts
    if charge_accounts.count > 0
      errors.add(:base, I18n.t('activerecord.models.project.check_for_charge_accounts'))
      return false
    end
    # Check for work orders
    if work_orders.count > 0
      errors.add(:base, I18n.t('activerecord.models.project.check_for_work_orders'))
      return false
    end
    # Check for purchase orders
    if purchase_orders.count > 0
      errors.add(:base, I18n.t('activerecord.models.project.check_for_purchase_orders'))
      return false
    end
    # Check for receipt notes
    if receipt_notes.count > 0
      errors.add(:base, I18n.t('activerecord.models.project.check_for_receipt_notes'))
      return false
    end
    # Check for offer requests
    if offer_requests.count > 0
      errors.add(:base, I18n.t('activerecord.models.project.check_for_offer_requests'))
      return false
    end
    # Check for offers
    if offers.count > 0
      errors.add(:base, I18n.t('activerecord.models.project.check_for_offers'))
      return false
    end
    # Check for supplier invoices
    if supplier_invoices.count > 0
      errors.add(:base, I18n.t('activerecord.models.project.check_for_supplier_invoices'))
      return false
    end
    # Check for delivery notes
    if delivery_notes.count > 0
      errors.add(:base, I18n.t('activerecord.models.project.check_for_delivery_notes'))
      return false
    end
    # Check for sale offers
    if sale_offers.count > 0
      errors.add(:base, I18n.t('activerecord.models.project.check_for_sale_offers'))
      return false
    end
    # Check for sale offer items
    if sale_offer_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.project.check_for_sale_offers'))
      return false
    end
  end
end
