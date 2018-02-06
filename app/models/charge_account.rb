# encoding: utf-8

class ChargeAccount < ActiveRecord::Base
  include ModelsModule

  belongs_to :project
  belongs_to :organization
  belongs_to :charge_group
  belongs_to :ledger_account
  attr_accessible :closed_at, :ledger_account_id, :name, :opened_at,
                  :project_id, :account_code, :organization_id, :charge_group_id
  attr_accessible :charge_account_ledger_accounts_attributes

  has_many :budget_items
  has_many :work_orders
  has_many :work_order_items
  has_many :work_order_workers
  has_many :work_order_tools
  has_many :work_order_vehicles
  has_many :work_order_subcontractors
  has_many :work_order_types
  has_many :work_order_type_accounts
  has_many :purchase_orders
  has_many :purchase_order_items
  has_many :receipt_notes
  has_many :receipt_note_items
  has_many :offer_requests
  has_many :offer_request_items
  has_many :offers
  has_many :offer_items
  has_many :supplier_invoices
  has_many :supplier_invoice_items
  has_many :delivery_notes
  has_many :delivery_note_items
  has_many :sale_offers
  has_many :sale_offer_items
  has_many :charge_account_ledger_accounts, dependent: :destroy
  has_many :invoices
  has_many :invoice_items

  # Nested attributes
  accepts_nested_attributes_for :charge_account_ledger_accounts,
                                :reject_if => :all_blank,
                                :allow_destroy => true

  has_paper_trail

  validates_associated :charge_account_ledger_accounts

  validates :account_code,    :presence => true,
                              :length => { :is => 10 },
                              :format => { with: /\A\d+\Z/, message: :code_invalid },
                              :numericality => { :only_integer => true, :greater_than => 0 },
                              :uniqueness => { :scope => [:organization_id, :charge_group_id] }
  validates :name,            :presence => true
  validates :opened_at,       :presence => true
  validates :organization,    :presence => true
  validates :charge_group,    :presence => true
  # validates :ledger_account,  :presence => true

  # Scopes
  scope :by_code, -> { order(:account_code) }
  #
  scope :belongs_to_project, -> project { where("project_id = ?", project).by_code }
  # generic where (eg. for Select2 from engines_controller)
  scope :g_where, -> w {
    joins("LEFT JOIN projects ON projects.id=project_id")
    .where(w)
    .by_code
  }
  scope :g_where_incomes, -> w {
    joins(:charge_group)
    .where("(charge_groups.flow = ? OR charge_groups.flow = ?) AND charge_accounts.closed_at IS NULL", 1, 3)
    .where(w)
    .by_code
  }
  scope :g_where_expenditures, -> w {
    joins(:charge_group)
    .where("(charge_groups.flow = ? OR charge_groups.flow = ?) AND charge_accounts.closed_at IS NULL", 2, 3)
    .where(w)
    .by_code
  }

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
    # Account code (Group code & project id & sequential number) => GGGG-PPPPNN
    account_code.blank? ? "" : account_code[0..3] + '-' + account_code[4..9]
  end

  def partial_name
    name.blank? ? "" : self.name[0,30]
  end

  def partial_group_name
    charge_group.blank? ? "" : charge_group.name[0,30]
  end

  def office
    project.nil? ? nil : project.office
  end

  def company
    project.nil? ? nil : project.company
  end

  #
  # Calculated fields
  #
  def active_yes_no
    closed_at.blank? ? I18n.t(:yes_on) : I18n.t(:no_off)
  end

  def flow
    self.charge_group.flow
  end

  # Aux methods for CSV
  def raw_number(_number, _d)
    formatted_number_without_delimiter(_number, _d)
  end

  def sanitize(s)
    !s.blank? ? sanitize_string(s.strip, true, true, true, false) : ''
  end

  # total cost and price for reports
  def bi_total(_project, _group)
    if _group.nil?
      budget_items.joins(:budget).where("budgets.project_id in (?)",_project).select('SUM(budget_items.amount) bi_t')
    else
      budget_items.joins(:budget,:charge_account).where("budgets.project_id in (?) AND charge_accounts.charge_group_id = ?",_project, _group).select('SUM(budget_items.amount) bi_t')
    end
  end

  def dni_total(_project, _group)
    if _group.nil?
      delivery_note_items.where('delivery_note_items.project_id in (?)',_project).select('SUM(delivery_note_items.quantity * delivery_note_items.cost) dni_t')
    else
      delivery_note_items.joins(:charge_account).where('delivery_note_items.project_id in (?) AND charge_accounts.charge_group_id = ?',_project, _group).select('SUM(delivery_note_items.quantity * delivery_note_items.cost) dni_t')
    end
  end

  def oi_total(_project, _group)
    if _group.nil?
      offer_items.where('offer_items.project_id in (?)',_project).select('SUM(offer_items.quantity * (offer_items.price - offer_items.discount)) oi_t')
    else
      offer_items.joins(:charge_account).where('offer_items.project_id in (?) AND charge_accounts.charge_group_id = ?',_project, _group).select('SUM(offer_items.quantity * (offer_items.price - offer_items.discount)) oi_t')
    end
  end

  def ori_total(_project, _group)
    if _group.nil?
      offer_request_items.where('offer_request_items.project_id in (?)',_project).select('SUM(offer_request_items.quantity * offer_request_items.price) ori_t')
    else
      offer_request_items.joins(:charge_account).where('offer_request_items.project_id in (?) AND charge_accounts.charge_group_id = ?',_project, _group).select('SUM(offer_request_items.quantity * offer_request_items.price) ori_t')
    end
  end

  def poi_total(_project, _group)
    if _group.nil?
      purchase_order_items.where('purchase_order_items.project_id in (?)',_project).select('SUM(purchase_order_items.quantity * (purchase_order_items.price - purchase_order_items.discount)) poi_t')
    else
      purchase_order_items.joins(:charge_account).where('purchase_order_items.project_id in (?) AND charge_accounts.charge_group_id = ?',_project, _group).select('SUM(purchase_order_items.quantity * (purchase_order_items.price - purchase_order_items.discount)) poi_t')
    end
  end

  def rni_total(_project, _group)
    if _group.nil?
      receipt_note_items.where('receipt_note_items.project_id in (?)',_project).select('SUM(receipt_note_items.quantity * (receipt_note_items.price - receipt_note_items.discount)) rni_t')
    else
      receipt_note_items.joins(:charge_account).where('receipt_note_items.project_id in (?) AND charge_accounts.charge_group_id = ?',_project, _group).select('SUM(receipt_note_items.quantity * (receipt_note_items.price - receipt_note_items.discount)) rni_t')
    end
  end

  def soi_total(_project, _group)
    if _group.nil?
      sale_offer_items.where('sale_offer_items.project_id in (?)',_project).select('SUM(sale_offer_items.quantity * (sale_offer_items.price - sale_offer_items.discount)) soi_t')
    else
      sale_offer_items.joins(:charge_account).where('sale_offer_items.project_id in (?) AND charge_accounts.charge_group_id = ?',_project, _group).select('SUM(sale_offer_items.quantity * (sale_offer_items.price - sale_offer_items.discount)) soi_t')
    end
  end

  def sii_total(_project, _group)
    if _group.nil?
      supplier_invoice_items.where('supplier_invoice_items.project_id in (?)',_project).select('SUM(supplier_invoice_items.quantity * (supplier_invoice_items.price - supplier_invoice_items.discount)) sii_t')
    else
      supplier_invoice_items.joins(:charge_account).where('supplier_invoice_items.project_id in (?) AND charge_accounts.charge_group_id = ?',_project, _group).select('SUM(supplier_invoice_items.quantity * (supplier_invoice_items.price - supplier_invoice_items.discount)) sii_t')
    end
  end

  def woi_total(_project, _group)
    if _group.nil?
      work_order_items.joins(:work_order).where("work_orders.project_id in (?)",_project).select('SUM(work_order_items.quantity * work_order_items.cost) woi_t')
    else
      work_order_items.joins(:work_order,:charge_account).where("work_orders.project_id in (?) AND charge_accounts.charge_group_id = ?",_project, _group).select('SUM(work_order_items.quantity * work_order_items.cost) woi_t')
    end
  end

  def wos_total(_project, _group)
    # work_order_subcontractors.sum(&:cost)
    if _group.nil?
      work_order_subcontractors.joins(:work_order).where("work_orders.project_id in (?)",_project).joins(purchase_order: :purchase_order_items).select('SUM((purchase_order_items.quantity * (purchase_order_items.price - purchase_order_items.discount)) - ((purchase_order_items.discount_pct / 100) * (purchase_order_items.quantity * (purchase_order_items.price - purchase_order_items.discount)) - purchase_order_items.discount )) wos_t ')
    else
      work_order_subcontractors.joins(:work_order,:charge_account).where("work_orders.project_id in (?) AND charge_accounts.charge_group_id = ?",_project, _group).joins(purchase_order: :purchase_order_items).select('SUM((purchase_order_items.quantity * (purchase_order_items.price - purchase_order_items.discount)) - ((purchase_order_items.discount_pct / 100) * (purchase_order_items.quantity * (purchase_order_items.price - purchase_order_items.discount)) - purchase_order_items.discount )) wos_t ')
    end
  end

  def wot_total(_project, _group)
    if _group.nil?
      work_order_tools.joins(:work_order).where("work_orders.project_id in (?)",_project).select('SUM(work_order_tools.minutes * work_order_tools.cost) wot_t')
    else
      work_order_tools.joins(:work_order,:charge_account).where("work_orders.project_id in (?) AND charge_accounts.charge_group_id = ?",_project, _group).select('SUM(work_order_tools.minutes * work_order_tools.cost) wot_t')
    end
  end

  def wov_total(_project, _group)
    if _group.nil?
      work_order_vehicles.joins(:work_order).where("work_orders.project_id in (?)",_project).select('SUM(work_order_vehicles.distance * work_order_vehicles.cost) wov_t')
    else
      work_order_vehicles.joins(:work_order,:charge_account).where("work_orders.project_id in (?) AND charge_accounts.charge_group_id = ?",_project, _group).select('SUM(work_order_vehicles.distance * work_order_vehicles.cost) wov_t')
    end
  end

  def wow_total(_project, _group)
    if _group.nil?
      work_order_workers.joins(:work_order).where("work_orders.project_id in (?)",_project).select('SUM(work_order_workers.hours * work_order_workers.cost) wow_t')
    else
      work_order_workers.joins(:work_order,:charge_account).where("work_orders.project_id in (?) AND charge_accounts.charge_group_id = ?",_project, _group).select('SUM(work_order_workers.hours * work_order_workers.cost) wow_t')
    end
  end

  def wo_total(_project, _group)
    woi_total(_project, _group).first.woi_t.to_s.to_d + wos_total(_project, _group).first.wos_t.to_s.to_d + wot_total(_project, _group).first.wot_t.to_s.to_d + wov_total(_project, _group).first.wov_t.to_s.to_d + wow_total(_project, _group).first.wow_t.to_s.to_d
  end

  def ii_total(_project, _group)
    if _group.nil?
      invoice_items.joins(invoice: :bill).where("bills.project_id in (?)",_project).select('SUM(invoice_items.quantity * (invoice_items.price - invoice_items.discount)) ii_total')
    else
      invoice_items.joins(:charge_account).where("charge_accounts.charge_group_id = ?",_group).joins(invoice: :bill).where("bills.project_id in (?) AND charge_accounts.charge_group_id = ?",_project, _group).select('SUM(invoice_items.quantity * (invoice_items.price - invoice_items.discount)) ii_total')
    end
  end

  # total cost and price for reports whit date
  def bi_total_date(_project, _from, _to, _group)
    if _group.nil?
      budget_items.joins(:budget).where("budgets.project_id in (?) AND budgets.approval_date >= ? AND budgets.approval_date <= ?",_project,_from,_to).select('SUM(budget_items.amount) bi_t')
    else
      budget_items.joins(:budget,:charge_account).where("budgets.project_id in (?) AND budgets.approval_date >= ? AND budgets.approval_date <= ? AND charge_accounts.charge_group_id = ?",_project,_from,_to, _group).select('SUM(budget_items.amount) bi_t')
    end
  end

  def dni_total_date(_project, _from, _to, _group)
    if _group.nil?
      delivery_note_items.joins(:delivery_note).where("delivery_notes.project_id in (?) AND delivery_notes.delivery_date >= ? AND delivery_notes.delivery_date <= ?",_project,_from,_to).select('SUM(delivery_note_items.quantity * delivery_note_items.cost) dni_t')
    else
      delivery_note_items.joins(:delivery_note,:charge_account).where("delivery_notes.project_id in (?) AND delivery_notes.delivery_date >= ? AND delivery_notes.delivery_date <= ? AND charge_accounts.charge_group_id = ?",_project,_from,_to, _group).select('SUM(delivery_note_items.quantity * delivery_note_items.cost) dni_t')
    end
  end

  def oi_total_date(_project, _from, _to, _group)
    if _group.nil?
      offer_items.joins(:offer).where("offers.project_id in (?) AND offers.offer_date >= ? AND offers.offer_date <= ?",_project,_from,_to).select('SUM(offer_items.quantity * (offer_items.price - offer_items.discount)) oi_t')
    else
      offer_items.joins(:offer,:charge_account).where("offers.project_id in (?) AND offers.offer_date >= ? AND offers.offer_date <= ? AND charge_accounts.charge_group_id = ?",_project,_from,_to, _group).select('SUM(offer_items.quantity * (offer_items.price - offer_items.discount)) oi_t')
    end
  end

  def ori_total_date(_project, _from, _to, _group)
    if _group.nil?
      offer_request_items.joins(:offer_request).where("offer_requests.project_id in (?) AND offer_requests.request_date >= ? AND offer_requests.request_date <= ?",_project,_from,_to).select('SUM(offer_request_items.quantity * offer_request_items.price) ori_t')
    else
      offer_request_items.joins(:offer_request,:charge_account).where("offer_requests.project_id in (?) AND offer_requests.request_date >= ? AND offer_requests.request_date <= ? AND charge_accounts.charge_group_id = ?",_project,_from,_to, _group).select('SUM(offer_request_items.quantity * offer_request_items.price) ori_t')
    end
  end

  def poi_total_date(_project, _from, _to, _group)
    if _group.nil?
      purchase_order_items.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",_project,_from,_to).select('SUM(purchase_order_items.quantity * (purchase_order_items.price - purchase_order_items.discount)) poi_t')
    else
      purchase_order_items.joins(:purchase_order,:charge_account).where("purchase_orders.project_id in (?) AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ? AND charge_accounts.charge_group_id = ?",_project,_from,_to, _group).select('SUM(purchase_order_items.quantity * (purchase_order_items.price - purchase_order_items.discount)) poi_t')
    end
  end

  def rni_total_date(_project, _from, _to, _group)
    if _group.nil?
      receipt_note_items.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",_project,_from,_to).select('SUM(receipt_note_items.quantity * (receipt_note_items.price - receipt_note_items.discount)) rni_t')
    else
      receipt_note_items.joins(:receipt_note,:charge_account).where("receipt_notes.project_id in (?) AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ? AND charge_accounts.charge_group_id = ?",_project,_from,_to, _group).select('SUM(receipt_note_items.quantity * (receipt_note_items.price - receipt_note_items.discount)) rni_t')
    end
  end

  def soi_total_date(_project, _from, _to, _group)
    if _group.nil?
      sale_offer_items.joins(:sale_offer).where("sale_offers.project_id in (?) AND sale_offers.offer_date >= ? AND sale_offers.offer_date <= ?",_project,_from,_to).select('SUM(sale_offer_items.quantity * (sale_offer_items.price - sale_offer_items.discount)) soi_t')
    else
      sale_offer_items.joins(:sale_offer,:charge_account).where("sale_offers.project_id in (?) AND sale_offers.offer_date >= ? AND sale_offers.offer_date <= ? AND charge_accounts.charge_group_id = ?",_project,_from,_to, _group).select('SUM(sale_offer_items.quantity * (sale_offer_items.price - sale_offer_items.discount)) soi_t')
    end
  end

  def sii_total_date(_project, _from, _to, _group)
    if _group.nil?
      supplier_invoice_items.joins(:supplier_invoice).where("supplier_invoices.project_id in (?) AND supplier_invoices.invoice_date >= ? AND supplier_invoices.invoice_date <= ?",_project,_from,_to).select('SUM(supplier_invoice_items.quantity * (supplier_invoice_items.price - supplier_invoice_items.discount)) sii_t')
    else
      supplier_invoice_items.joins(:supplier_invoice,:charge_account).where("supplier_invoices.project_id in (?) AND supplier_invoices.invoice_date >= ? AND supplier_invoices.invoice_date <= ? AND charge_accounts.charge_group_id = ?",_project,_from,_to, _group).select('SUM(supplier_invoice_items.quantity * (supplier_invoice_items.price - supplier_invoice_items.discount)) sii_t')
    end
  end

  def woi_total_date(_project, _from, _to, _group)
    if _group.nil?
      work_order_items.joins(:work_order).where("work_orders.project_id in (?) AND work_orders.created_at >= ? AND work_orders.created_at <= ?",_project,_from,_to).select('SUM(work_order_items.quantity * work_order_items.cost) woi_t')
    else
      work_order_items.joins(:work_order,:charge_account).where("work_orders.project_id in (?) AND work_orders.created_at >= ? AND work_orders.created_at <= ? AND charge_accounts.charge_group_id = ?",_project,_from,_to, _group).select('SUM(work_order_items.quantity * work_order_items.cost) woi_t')
    end
  end

  def wos_total_date(_project, _from, _to, _group)
    # work_order_subcontractors.sum(&:cost)
    if _group.nil?
      work_order_subcontractors.joins(:work_order).where("work_orders.project_id in (?) AND work_orders.created_at >= ? AND work_orders.created_at <= ?",_project,_from,_to).joins(purchase_order: :purchase_order_items).select('SUM((purchase_order_items.quantity * (purchase_order_items.price - purchase_order_items.discount)) - ((purchase_order_items.discount_pct / 100) * (purchase_order_items.quantity * (purchase_order_items.price - purchase_order_items.discount)) - purchase_order_items.discount )) wos_t ')
    else
      work_order_subcontractors.joins(:work_order,:charge_account).where("work_orders.project_id in (?) AND work_orders.created_at >= ? AND work_orders.created_at <= ? AND charge_accounts.charge_group_id = ?",_project,_from,_to, _group).joins(purchase_order: :purchase_order_items).select('SUM((purchase_order_items.quantity * (purchase_order_items.price - purchase_order_items.discount)) - ((purchase_order_items.discount_pct / 100) * (purchase_order_items.quantity * (purchase_order_items.price - purchase_order_items.discount)) - purchase_order_items.discount )) wos_t ')
    end
  end

  def wot_total_date(_project, _from, _to, _group)
    if _group.nil?
      work_order_tools.joins(:work_order).where("work_orders.project_id in (?) AND work_orders.created_at >= ? AND work_orders.created_at <= ?",_project,_from,_to).select('SUM(work_order_tools.minutes * work_order_tools.cost) wot_t')
    else
      work_order_tools.joins(:work_order,:charge_account).where("work_orders.project_id in (?) AND work_orders.created_at >= ? AND work_orders.created_at <= ? AND charge_accounts.charge_group_id = ?",_project,_from,_to, _group).select('SUM(work_order_tools.minutes * work_order_tools.cost) wot_t')
    end
  end

  def wov_total_date(_project, _from, _to, _group)
    if _group.nil?
      work_order_vehicles.joins(:work_order).where("work_orders.project_id in (?) AND work_orders.created_at >= ? AND work_orders.created_at <= ?",_project,_from,_to).select('SUM(work_order_vehicles.distance * work_order_vehicles.cost) wov_t')
    else
      work_order_vehicles.joins(:work_order,:charge_account).where("work_orders.project_id in (?) AND work_orders.created_at >= ? AND work_orders.created_at <= ? AND charge_accounts.charge_group_id = ?",_project,_from,_to, _group).select('SUM(work_order_vehicles.distance * work_order_vehicles.cost) wov_t')
    end
  end

  def wow_total_date(_project, _from, _to, _group)
    if _group.nil?
      work_order_workers.joins(:work_order).where("work_orders.project_id in (?) AND work_orders.created_at >= ? AND work_orders.created_at <= ?",_project,_from,_to).select('SUM(work_order_workers.hours * work_order_workers.cost) wow_t')
    else
      work_order_workers.joins(:work_order,:charge_account).where("work_orders.project_id in (?) AND work_orders.created_at >= ? AND work_orders.created_at <= ? AND charge_accounts.charge_group_id = ?",_project,_from,_to, _group).select('SUM(work_order_workers.hours * work_order_workers.cost) wow_t')
    end
  end

  def wo_total_date(_project, _from, _to, _group)
    woi_total_date(_project, _from, _to, _group).first.woi_t.to_s.to_d + wos_total_date(_project, _from, _to, _group).first.wos_t.to_s.to_d + wot_total_date(_project, _from, _to, _group).first.wot_t.to_s.to_d + wov_total_date(_project, _from, _to, _group).first.wov_t.to_s.to_d + wow_total_date(_project, _from, _to, _group).first.wow_t.to_s.to_d
  end

  def ii_total_date(_project, _from, _to, _group)
    if _group.nil?
      invoice_items.joins(invoice: :bill).where("bills.project_id in (?) AND invoices.invoice_date >= ? AND invoices.invoice_date <= ?",_project,_from,_to).select('SUM(invoice_items.quantity * (invoice_items.price - invoice_items.discount)) ii_total')
    else
      invoice_items.joins(:charge_account).where("charge_accounts.charge_group_id = ?",_group).joins(invoice: :bill).where("bills.project_id in (?) AND invoices.invoice_date >= ? AND invoices.invoice_date <= ?",_project,_from,_to).select('SUM(invoice_items.quantity * (invoice_items.price - invoice_items.discount)) ii_total')
    end
  end

  #
  # Class (self) user defined methods
  #
  def self.incomes(project = nil)
    if project.blank?
      joins(:charge_group).where("(charge_groups.flow = ? OR charge_groups.flow = ?) AND charge_accounts.closed_at IS NULL", 1, 3).order(:account_code)
    else
      joins(:charge_group).where("project_id = ? AND (charge_groups.flow = ? OR charge_groups.flow = ?) AND charge_accounts.closed_at IS NULL", project, 1, 3).order(:account_code)
    end
  end

  def self.expenditures(project = nil)
    if project.blank?
      joins(:charge_group).where("(charge_groups.flow = ? OR charge_groups.flow = ?) AND charge_accounts.closed_at IS NULL", 2, 3).order(:account_code)
    else
      joins(:charge_group).where("project_id = ? AND (charge_groups.flow = ? OR charge_groups.flow = ?) AND charge_accounts.closed_at IS NULL", project, 2, 3).order(:account_code)
    end
  end

  # def self.expenditures
  #   joins(:charge_group).where("(charge_groups.flow = ? OR charge_groups.flow = ?) AND charge_accounts.closed_at IS NULL", 2, 3).order(:account_code)
  # end

  def self.incomes_and_expenditures
    joins(:charge_group).where("charge_groups.flow = ? AND charge_accounts.closed_at IS NULL", 3).order(:account_code)
  end

  def self.incomes_only
    joins(:charge_group).where("charge_groups.flow = ? AND charge_accounts.closed_at IS NULL", 1).order(:account_code)
  end

  def self.expenditures_only
    joins(:charge_group).where("charge_groups.flow = ? AND charge_accounts.closed_at IS NULL", 2).order(:account_code)
  end

  def self.expenditures_no_project
    joins(:charge_group).where("(charge_groups.flow = ? OR charge_groups.flow = ?) AND charge_accounts.closed_at IS NULL AND charge_accounts.project_id IS NULL", 2, 3).order(:account_code)
  end

  def self.no_project
    where("charge_accounts.closed_at IS NULL AND charge_accounts.project_id IS NULL").order(:account_code)
  end

  def self.to_csv(array,project)
    attributes = [ array[0].sanitize(I18n.t("activerecord.attributes.charge_group.group_code")),
                   array[0].sanitize(I18n.t("activerecord.attributes.charge_group.budget_heading")),
                   array[0].sanitize(I18n.t("activerecord.attributes.charge_group.group_code")),
                   array[0].sanitize(I18n.t("activerecord.attributes.charge_account.charge_group")),
                   array[0].sanitize(I18n.t("activerecord.attributes.charge_account.account_code")),
                   array[0].sanitize(I18n.t("activerecord.attributes.charge_account.name")),
                   array[0].sanitize(I18n.t("activerecord.attributes.project.project_code")),
                   array[0].sanitize(I18n.t("activerecord.attributes.project.name")),
                   array[0].sanitize(I18n.t("activerecord.attributes.charge_account.ledger_account")),
                   array[0].sanitize(I18n.t("ag2_tech.ag2_tech_track.every_report.work_orders")),
                   array[0].sanitize(I18n.t("ag2_tech.ag2_tech_track.every_report.receipt_notes")),
                   array[0].sanitize(I18n.t("ag2_tech.ag2_tech_track.every_report.delivery_notes")),
                   array[0].sanitize(I18n.t("ag2_tech.ag2_tech_track.every_report.supplier_invoice_items")),
                   array[0].sanitize(I18n.t("ag2_tech.ag2_tech_track.every_report.invoice_items")),
                   array[0].sanitize(I18n.t("activerecord.attributes.charge_account.opened_at")),
                   array[0].sanitize(I18n.t("activerecord.attributes.charge_account.closed_at")) ]
    col_sep = I18n.locale == :es ? ";" : ","
    CSV.generate(headers: true, col_sep: col_sep, row_sep: "\r\n") do |csv|
      csv << attributes
      array.each do |i|
        i001 = i.wo_total(project,group).blank? ? "0,00" : i.raw_number(i.wo_total(project,group), 2)
        i002 = i.rni_total(project,group).blank? ? "0,00" : i.raw_number(i.rni_total(project,group).first.rni_t, 2)
        i003 = i.dni_total(project,group).blank? ? "0,00" : i.raw_number(i.dni_total(project,group).first.dni_t, 2)
        i004 = i.sii_total(project,group).blank? ? "0,00" : i.raw_number(i.sii_total(project,group).first.sii_t, 2)
        i005 = i.ii_total(project,group).blank? ? "0,00" : i.raw_number(i.ii_total(project,group).first.ii_t, 2)
        i006 = i.opened_at.strftime("%d/%m/%Y") unless i.opened_at.blank?
        i007 = i.closed_at.strftime("%d/%m/%Y") unless i.closed_at.blank?
        csv << [ i.try(:charge_group).try(:budget_heading).try(:heading_code),
                 i.try(:charge_group).try(:budget_heading).try(:name),
                 i.try(:charge_group).try(:group_code),
                 i.try(:charge_group).try(:name),
                 i.full_code,
                 i.name,
                 i.try(:project).try(:full_code),
                 i.try(:project).try(:name),
                 i.try(:ledger_account).try(:full_name),
                 i001,
                 i002,
                 i003,
                 i004,
                 i005,
                 i006,
                 i007 ]
      end
    end
  end

  def self.to_date_csv(array,project,from,to,group)
    attributes = [ array[0].sanitize(I18n.t("activerecord.attributes.charge_group.group_code")),
                   array[0].sanitize(I18n.t("activerecord.attributes.charge_group.budget_heading")),
                   array[0].sanitize(I18n.t("activerecord.attributes.charge_group.group_code")),
                   array[0].sanitize(I18n.t("activerecord.attributes.charge_account.charge_group")),
                   array[0].sanitize(I18n.t("activerecord.attributes.charge_account.account_code")),
                   array[0].sanitize(I18n.t("activerecord.attributes.charge_account.name")),
                   array[0].sanitize(I18n.t("activerecord.attributes.project.project_code")),
                   array[0].sanitize(I18n.t("activerecord.attributes.project.name")),
                   array[0].sanitize(I18n.t("activerecord.attributes.charge_account.ledger_account")),
                   array[0].sanitize(I18n.t("ag2_tech.ag2_tech_track.every_report.work_orders")),
                   array[0].sanitize(I18n.t("ag2_tech.ag2_tech_track.every_report.receipt_notes")),
                   array[0].sanitize(I18n.t("ag2_tech.ag2_tech_track.every_report.delivery_notes")),
                   array[0].sanitize(I18n.t("ag2_tech.ag2_tech_track.every_report.supplier_invoice_items")),
                   array[0].sanitize(I18n.t("ag2_tech.ag2_tech_track.every_report.invoice_items")),
                   array[0].sanitize(I18n.t("activerecord.attributes.charge_account.opened_at")),
                   array[0].sanitize(I18n.t("activerecord.attributes.charge_account.closed_at")) ]
    col_sep = I18n.locale == :es ? ";" : ","
    CSV.generate(headers: true, col_sep: col_sep, row_sep: "\r\n") do |csv|
      csv << attributes
      array.each do |i|
        i001 = i.wo_total_date(project,from,to,group).blank? ? "0,00" : i.raw_number(i.wo_total_date(project,from,to,group), 2)
        i002 = i.rni_total_date(project,from,to,group).blank? ? "0,00" : i.raw_number(i.rni_total_date(project,from,to,group).first.rni_t, 2)
        i003 = i.dni_total_date(project,from,to,group).blank? ? "0,00" : i.raw_number(i.dni_total_date(project,from,to,group).first.dni_t, 2)
        i004 = i.sii_total_date(project,from,to,group).blank? ? "0,00" : i.raw_number(i.sii_total_date(project,from,to,group).first.sii_t, 2)
        i005 = i.ii_total_date(project,from,to,group).blank? ? "0,00" : i.raw_number(i.ii_total_date(project,from,to,group).first.ii_t, 2)
        i006 = i.opened_at.strftime("%d/%m/%Y") unless i.opened_at.blank?
        i007 = i.closed_at.strftime("%d/%m/%Y") unless i.closed_at.blank?
        csv << [ i.try(:charge_group).try(:budget_heading).try(:heading_code),
                 i.try(:charge_group).try(:budget_heading).try(:name),
                 i.try(:charge_group).try(:group_code),
                 i.try(:charge_group).try(:name),
                 i.full_code,
                 i.name,
                 i.try(:project).try(:full_code),
                 i.try(:project).try(:name),
                 i.try(:ledger_account).try(:full_name),
                 i001,
                 i002,
                 i003,
                 i004,
                 i005,
                 i006,
                 i007 ]
      end
    end
  end

  def self.to_group_date_csv(array,project,from,to,group)
    attributes = [ array[0].sanitize(I18n.t("activerecord.attributes.charge_group.group_code")),
                   array[0].sanitize(I18n.t("activerecord.attributes.charge_group.budget_heading")),
                   array[0].sanitize(I18n.t("activerecord.attributes.charge_group.group_code")),
                   array[0].sanitize(I18n.t("activerecord.attributes.charge_account.charge_group")),
                   array[0].sanitize(I18n.t("ag2_tech.ag2_tech_track.every_report.work_orders")),
                   array[0].sanitize(I18n.t("ag2_tech.ag2_tech_track.every_report.receipt_notes")),
                   array[0].sanitize(I18n.t("ag2_tech.ag2_tech_track.every_report.delivery_notes")),
                   array[0].sanitize(I18n.t("ag2_tech.ag2_tech_track.every_report.supplier_invoice_items")),
                   array[0].sanitize(I18n.t("ag2_tech.ag2_tech_track.every_report.invoice_items"))]
    col_sep = I18n.locale == :es ? ";" : ","
    CSV.generate(headers: true, col_sep: col_sep, row_sep: "\r\n") do |csv|
      csv << attributes
      array.each do |i|
        i001 = i.charge_group.wo_total_date(project,from,to,group).blank? ? "0,00" : i.raw_number(i.charge_group.wo_total_date(project,from,to,group), 2)
        i002 = i.charge_group.rni_total_date(project,from,to,group).blank? ? "0,00" : i.raw_number(i.charge_group.rni_total_date(project,from,to,group).first.rni_t, 2)
        i003 = i.charge_group.dni_total_date(project,from,to,group).blank? ? "0,00" : i.raw_number(i.charge_group.dni_total_date(project,from,to,group).first.dni_t, 2)
        i004 = i.charge_group.sii_total_date(project,from,to,group).blank? ? "0,00" : i.raw_number(i.charge_group.sii_total_date(project,from,to,group).first.sii_t, 2)
        i005 = i.charge_group.ii_total_date(project,from,to,group).blank? ? "0,00" : i.raw_number(i.charge_group.ii_total_date(project,from,to).first.ii_t, 2)
        csv << [ i.try(:charge_group).try(:budget_heading).try(:heading_code),
                 i.try(:charge_group).try(:budget_heading).try(:name),
                 i.try(:charge_group).try(:group_code),
                 i.try(:charge_group).try(:name),
                 i001,
                 i002,
                 i003,
                 i004,
                 i005]
      end
    end
  end

  #
  # Records navigator
  #
  def to_first
    ChargeAccount.order("account_code").first
  end

  def to_prev
    ChargeAccount.where("account_code < ?", account_code).order("account_code").last
  end

  def to_next
    ChargeAccount.where("account_code > ?", account_code).order("account_code").first
  end

  def to_last
    ChargeAccount.order("account_code").last
  end

  searchable do
    text :account_code, :name
    string :account_code, :multiple => true   # Multiple search values accepted in one search (inverse_no_search)
    integer :project_id, :multiple => true
    integer :charge_group_id
    integer :organization_id
    string :sort_no do
      account_code
    end
  end

  private

  def check_for_dependent_records
    # Check for budget items
    if budget_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.charge_account.check_for_budget_items'))
      return false
    end
    # Check for work orders
    if work_orders.count > 0
      errors.add(:base, I18n.t('activerecord.models.charge_account.check_for_work_orders'))
      return false
    end
    # Check for purchase orders
    if purchase_orders.count > 0
      errors.add(:base, I18n.t('activerecord.models.charge_account.check_for_purchase_orders'))
      return false
    end
    # Check for purchase order items
    if purchase_order_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.charge_account.check_for_purchase_orders'))
      return false
    end
    # Check for receipt notes
    if receipt_notes.count > 0
      errors.add(:base, I18n.t('activerecord.models.charge_account.check_for_receipt_notes'))
      return false
    end
    # Check for receipt note items
    if receipt_note_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.charge_account.check_for_receipt_notes'))
      return false
    end
    # Check for delivery notes
    if delivery_notes.count > 0
      errors.add(:base, I18n.t('activerecord.models.charge_account.check_for_delivery_notes'))
      return false
    end
    # Check for delivery note items
    if delivery_note_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.charge_account.check_for_delivery_notes'))
      return false
    end
    # Check for offer requests
    if offer_requests.count > 0
      errors.add(:base, I18n.t('activerecord.models.charge_account.check_for_offer_requests'))
      return false
    end
    # Check for offer request items
    if offer_request_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.charge_account.check_for_offer_requests'))
      return false
    end
    # Check for offers
    if offers.count > 0
      errors.add(:base, I18n.t('activerecord.models.charge_account.check_for_offers'))
      return false
    end
    # Check for offer items
    if offer_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.charge_account.check_for_offers'))
      return false
    end
    # Check for supplier invoices
    if supplier_invoices.count > 0
      errors.add(:base, I18n.t('activerecord.models.charge_account.check_for_supplier_invoices'))
      return false
    end
    # Check for supplier invoice items
    if supplier_invoice_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.charge_account.check_for_supplier_invoices'))
      return false
    end
    # Check for sale offers
    if sale_offers.count > 0
      errors.add(:base, I18n.t('activerecord.models.charge_account.check_for_sale_offers'))
      return false
    end
    # Check for sale offer items
    if sale_offer_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.charge_account.check_for_sale_offers'))
      return false
    end
  end
end
