class ChargeGroup < ActiveRecord::Base
  belongs_to :organization
  belongs_to :budget_heading
  belongs_to :ledger_account
  attr_accessible :flow, :group_code, :ledger_account_id, :name, :organization_id, :budget_heading_id

  has_many :charge_accounts
  has_many :budget_items, through: :charge_accounts
  has_many :delivery_note_items, through: :charge_accounts
  has_many :offer_items, through: :charge_accounts
  has_many :offer_request_items, through: :charge_accounts
  has_many :purchase_order_items, through: :charge_accounts
  has_many :receipt_note_items, through: :charge_accounts
  has_many :sale_offer_items, through: :charge_accounts
  has_many :supplier_invoice_items, through: :charge_accounts
  has_many :work_order_items, through: :charge_accounts
  has_many :work_order_subcontractors, through: :charge_accounts
  has_many :work_order_tools, through: :charge_accounts
  has_many :work_order_vehicles, through: :charge_accounts
  has_many :work_order_workers, through: :charge_accounts
  has_many :invoice_items, through: :charge_accounts
  has_many :delivery_note_items, through: :charge_accounts
  has_many :charge_group_ledger_accounts, dependent: :destroy

  # Nested attributes
  accepts_nested_attributes_for :charge_group_ledger_accounts,
                                :reject_if => :all_blank,
                                :allow_destroy => true

  has_paper_trail

  validates_associated :charge_group_ledger_accounts

  validates :group_code,      :presence => true,
                              :length => { :is => 4 },
                              :format => { with: /\A\d+\Z/, message: :code_invalid },
                              :numericality => { :only_integer => true, :greater_than => 0 },
                              :uniqueness => { :scope => :organization_id }
  validates :name,            :presence => true
  validates :flow,            :presence => true,
                              :numericality => { :only_integer => true, :greater_than => 0, :less_than_or_equal_to => 3 }
  validates :organization,    :presence => true
  validates :budget_heading,  :presence => true

  before_destroy :check_for_dependent_records

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = ''
    if !self.group_code.blank?
      full_name += self.group_code
    end
    if !self.name.blank?
      full_name += " " + self.name[0,40]
    end
    full_name
  end

  def flow_label
    flow_label = case flow
      when 1 then I18n.t('activerecord.attributes.charge_group.flow_1')       #Income
      when 2 then I18n.t('activerecord.attributes.charge_group.flow_2')       #Expenditure
      when 3 then I18n.t('activerecord.attributes.charge_group.flow_3_show')  #Both
      else 'N/A'
    end
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
      invoice_items.joins(invoice: :bill).where("bills.project_id in (?)",_project).select('SUM(invoice_items.quantity * (invoice_items.price - invoice_items.discount)) ii_t')
    else
      invoice_items.joins(:charge_account).where("charge_accounts.charge_group_id = ?",_group).joins(invoice: :bill).where("bills.project_id in (?) AND charge_accounts.charge_group_id = ?",_project, _group).select('SUM(invoice_items.quantity * (invoice_items.price - invoice_items.discount)) ii_t')
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
      invoice_items.joins(invoice: :bill).where("bills.project_id in (?) AND invoices.invoice_date >= ? AND invoices.invoice_date <= ?",_project,_from,_to).select('SUM(invoice_items.quantity * (invoice_items.price - invoice_items.discount)) ii_t')
    else
      invoice_items.joins(:charge_account).where("charge_accounts.charge_group_id = ?",_group).joins(invoice: :bill).where("bills.project_id in (?) AND invoices.invoice_date >= ? AND invoices.invoice_date <= ?",_project,_from,_to).select('SUM(invoice_items.quantity * (invoice_items.price - invoice_items.discount)) ii_t')
    end
  end

  #
  # Records navigator
  #
  def to_first
    ChargeGroup.order("group_code").first
  end

  def to_prev
    ChargeGroup.where("group_code < ?", group_code).order("group_code").last
  end

  def to_next
    ChargeGroup.where("group_code > ?", group_code).order("group_code").first
  end

  def to_last
    ChargeGroup.order("group_code").last
  end

  private

  def check_for_dependent_records
    # Check for charge accounts
    if charge_accounts.count > 0
      errors.add(:base, I18n.t('activerecord.models.charge_group.check_for_charge_accounts'))
      return false
    end
  end
end
