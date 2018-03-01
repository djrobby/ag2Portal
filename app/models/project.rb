# encoding: utf-8

class Project < ActiveRecord::Base
  include ModelsModule

  has_and_belongs_to_many :users, :join_table => :users_projects
  belongs_to :organization
  belongs_to :company
  belongs_to :office
  belongs_to :project_type
  belongs_to :ledger_account
  belongs_to :water_supply_contract_template, class_name: "ContractTemplate", foreign_key: "water_supply_contract_template_id"
  belongs_to :water_connection_contract_template, class_name: "ContractTemplate", foreign_key: "water_connection_contract_template_id"

  attr_accessible :closed_at, :ledger_account_id, :name, :opened_at, :project_code,
                  :office_id, :company_id, :organization_id, :project_type_id,
                  :max_order_total, :max_order_price,
                  :water_supply_contract_template_id, :water_connection_contract_template_id

  has_many :charge_accounts
  has_many :work_orders
  has_many :work_order_items, through: :work_orders
  has_many :work_order_subcontractors, through: :work_orders
  has_many :work_order_tools, through: :work_orders
  has_many :work_order_vehicles, through: :work_orders
  has_many :work_order_workers, through: :work_orders
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
  has_many :bills
  has_many :invoices, through: :bills
  has_many :invoice_items, through: :invoices
  has_many :billing_periods
  has_many :billable_items
  has_many :tariffs, through: :billable_items
  has_many :billable_concepts, through: :billable_items
  has_many :pre_readings
  has_many :readings
  has_many :reading_routes
  has_many :tariff_shemes
  has_many :regulations
  has_many :contracting_requests
  has_many :ledger_accounts
  has_many :invoice_current_debts

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
  scope :ser_or_tca, -> { where("project_type_id = ? OR project_type_id = ?", 1, 2).order(:id) }
  scope :ser_or_tca_order_type, -> { where("project_type_id = ? OR project_type_id = ?", 1, 2).order(:project_type_id) }

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

  # Aux methods for CSV
  def raw_number(_number, _d)
    formatted_number_without_delimiter(_number, _d)
  end

  def sanitize(s)
    !s.blank? ? sanitize_string(s.strip, true, true, true, false) : ''
  end

  #
  # Class (self) user defined methods
  #
  def self.active_only
    where("closed_at IS NULL OR closed_at >= ?", Date.today).order(:project_code)
  end

  def self.to_csv(array,project,office)
    attributes = [ array[0].sanitize("Id" + " " + I18n.t("activerecord.models.company.one")),
                   array[0].sanitize(I18n.t("activerecord.models.company.one")),
                   array[0].sanitize(I18n.t("activerecord.attributes.project.project_code")),
                   array[0].sanitize(I18n.t("activerecord.attributes.project.office")),
                   array[0].sanitize(I18n.t("activerecord.attributes.project.project_code")),
                   array[0].sanitize(I18n.t("activerecord.attributes.project.name")),
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
        i001 = i.wo_total(project,office).blank? ? "0,00" : i.raw_number(i.wo_total(project,office), 2)
        i002 = i.rni_total(project,office).blank? ? "0,00" : i.raw_number(i.rni_total(project,office).first.rni_t, 2)
        i003 = i.dni_total(project,office).blank? ? "0,00" : i.raw_number(i.dni_total(project,office).first.dni_t, 2)
        i004 = i.sii_total(project,office).blank? ? "0,00" : i.raw_number(i.sii_total(project,office).first.sii_t, 2)
        i005 = i.ii_total(project,office).blank? ? "0,00" : i.raw_number(i.ii_total(project,office).first.ii_t, 2)
        i006 = i.opened_at.strftime("%d/%m/%Y") unless i.opened_at.blank?
        i007 = i.closed_at.strftime("%d/%m/%Y") unless i.closed_at.blank?
        csv << [ i.try(:office).try(:company).try(:id),
                 i.try(:office).try(:company).try(:name),
                 i.try(:office).try(:office_code),
                 i.try(:office).try(:name),
                 i.full_code,
                 i.name,
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

  def self.to_date_csv(array,project,from,to,office)
    attributes = [ array[0].sanitize("Id" + " " + I18n.t("activerecord.models.company.one")),
                   array[0].sanitize(I18n.t("activerecord.models.company.one")),
                   array[0].sanitize(I18n.t("activerecord.attributes.project.project_code")),
                   array[0].sanitize(I18n.t("activerecord.attributes.project.office")),
                   array[0].sanitize(I18n.t("activerecord.attributes.project.project_code")),
                   array[0].sanitize(I18n.t("activerecord.attributes.project.name")),
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
        i001 = i.wo_total_date(project,from,to,office).blank? ? "0,00" : i.raw_number(i.wo_total_date(project,from,to,office), 2)
        i002 = i.rni_total_date(project,from,to,office).blank? ? "0,00" : i.raw_number(i.rni_total_date(project,from,to,office).first.rni_t, 2)
        i003 = i.dni_total_date(project,from,to,office).blank? ? "0,00" : i.raw_number(i.dni_total_date(project,from,to,office).first.dni_t, 2)
        i004 = i.sii_total_date(project,from,to,office).blank? ? "0,00" : i.raw_number(i.sii_total_date(project,from,to,office).first.sii_t, 2)
        i005 = i.ii_total_date(project,from,to,office).blank? ? "0,00" : i.raw_number(i.ii_total_date(project,from,to,office).first.ii_t, 2)
        i006 = i.opened_at.strftime("%d/%m/%Y") unless i.opened_at.blank?
        i007 = i.closed_at.strftime("%d/%m/%Y") unless i.closed_at.blank?
        csv << [ i.try(:office).try(:company).try(:id),
                 i.try(:office).try(:company).try(:name),
                 i.try(:office).try(:office_code),
                 i.try(:office).try(:name),
                 i.full_code,
                 i.name,
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

  # total cost and price for reports
  def dni_total(_project, _office)
    if _office.nil?
      delivery_note_items.where('delivery_note_items.project_id in (?)',_project).select('SUM(delivery_note_items.quantity * delivery_note_items.cost) dni_t')
    else
      delivery_note_items.joins(:project).where('delivery_note_items.project_id in (?) AND projects.office_id = ?',_project, _office).select('SUM(delivery_note_items.quantity * delivery_note_items.cost) dni_t')
    end
  end

  def oi_total(_project, _office)
    if _office.nil?
      offer_items.where('offer_items.project_id in (?)',_project).select('SUM(offer_items.quantity * (offer_items.price - offer_items.discount)) oi_t')
    else
      offer_items.joins(:project).where('offer_items.project_id in (?) AND projects.office_id = ?',_project, _office).select('SUM(offer_items.quantity * (offer_items.price - offer_items.discount)) oi_t')
    end
  end

  def ori_total(_project, _office)
    if _office.nil?
      offer_request_items.where('offer_request_items.project_id in (?)',_project).select('SUM(offer_request_items.quantity * offer_request_items.price) ori_t')
    else
      offer_request_items.joins(:project).where('offer_request_items.project_id in (?) AND projects.office_id = ?',_project, _office).select('SUM(offer_request_items.quantity * offer_request_items.price) ori_t')
    end
  end

  def poi_total(_project, _office)
    if _office.nil?
      purchase_order_items.where('purchase_order_items.project_id in (?)',_project).select('SUM(purchase_order_items.quantity * (purchase_order_items.price - purchase_order_items.discount)) poi_t')
    else
      purchase_order_items.joins(:project).where('purchase_order_items.project_id in (?) AND projects.office_id = ?',_project, _office).select('SUM(purchase_order_items.quantity * (purchase_order_items.price - purchase_order_items.discount)) poi_t')
    end
  end

  def rni_total(_project, _office)
    if _office.nil?
      receipt_note_items.where('receipt_note_items.project_id in (?)',_project).select('SUM(receipt_note_items.quantity * (receipt_note_items.price - receipt_note_items.discount)) rni_t')
    else
      receipt_note_items.joins(:project).where('receipt_note_items.project_id in (?) AND projects.office_id = ?',_project, _office).select('SUM(receipt_note_items.quantity * (receipt_note_items.price - receipt_note_items.discount)) rni_t')
    end
  end

  def soi_total(_project, _office)
    if _office.nil?
      sale_offer_items.where('sale_offer_items.project_id in (?)',_project).select('SUM(sale_offer_items.quantity * (sale_offer_items.price - sale_offer_items.discount)) soi_t')
    else
      sale_offer_items.joins(:project).where('sale_offer_items.project_id in (?) AND projects.office_id = ?',_project, _office).select('SUM(sale_offer_items.quantity * (sale_offer_items.price - sale_offer_items.discount)) soi_t')
    end
  end

  def sii_total(_project, _office)
    if _office.nil?
      supplier_invoice_items.where('supplier_invoice_items.project_id in (?)',_project).select('SUM(supplier_invoice_items.quantity * (supplier_invoice_items.price - supplier_invoice_items.discount)) sii_t')
    else
      supplier_invoice_items.joins(:project).where('supplier_invoice_items.project_id in (?) AND projects.office_id = ?',_project, _office).select('SUM(supplier_invoice_items.quantity * (supplier_invoice_items.price - supplier_invoice_items.discount)) sii_t')
    end
  end

  def woi_total(_project, _office)
    if _office.nil?
      work_order_items.joins(:work_order).where("work_orders.project_id in (?)",_project).select('SUM(work_order_items.quantity * work_order_items.cost) woi_t')
    else
      work_order_items.joins(work_order: :project).where("work_orders.project_id in (?) AND projects.office_id = ?",_project, _office).select('SUM(work_order_items.quantity * work_order_items.cost) woi_t')
    end
  end

  def wos_total(_project, _office)
    # work_order_subcontractors.sum(&:cost)
    if _office.nil?
      work_order_subcontractors.joins(:work_order).where("work_orders.project_id in (?)",_project).joins(purchase_order: :purchase_order_items).select('SUM((purchase_order_items.quantity * (purchase_order_items.price - purchase_order_items.discount)) - ((purchase_order_items.discount_pct / 100) * (purchase_order_items.quantity * (purchase_order_items.price - purchase_order_items.discount)) - purchase_order_items.discount )) wos_t ')
    else
      work_order_subcontractors.joins(work_order: :project).where("work_orders.project_id in (?) AND projects.office_id = ?",_project, _office).joins(purchase_order: :purchase_order_items).select('SUM((purchase_order_items.quantity * (purchase_order_items.price - purchase_order_items.discount)) - ((purchase_order_items.discount_pct / 100) * (purchase_order_items.quantity * (purchase_order_items.price - purchase_order_items.discount)) - purchase_order_items.discount )) wos_t ')
    end
  end

  def wot_total(_project, _office)
    if _office.nil?
      work_order_tools.joins(:work_order).where("work_orders.project_id in (?)",_project).select('SUM(work_order_tools.minutes * work_order_tools.cost) wot_t')
    else
      work_order_tools.joins(work_order: :project).where("work_orders.project_id in (?) AND projects.office_id = ?",_project, _office).select('SUM(work_order_tools.minutes * work_order_tools.cost) wot_t')
    end
  end

  def wov_total(_project, _office)
    if _office.nil?
      work_order_vehicles.joins(:work_order).where("work_orders.project_id in (?)",_project).select('SUM(work_order_vehicles.distance * work_order_vehicles.cost) wov_t')
    else
      work_order_vehicles.joins(work_order: :project).where("work_orders.project_id in (?) AND projects.office_id = ?",_project, _office).select('SUM(work_order_vehicles.distance * work_order_vehicles.cost) wov_t')
    end
  end

  def wow_total(_project, _office)
    if _office.nil?
      work_order_workers.joins(:work_order).where("work_orders.project_id in (?)",_project).select('SUM(work_order_workers.hours * work_order_workers.cost) wow_t')
    else
      work_order_workers.joins(work_order: :project).where("work_orders.project_id in (?) AND projects.office_id = ?",_project, _office).select('SUM(work_order_workers.hours * work_order_workers.cost) wow_t')
    end
  end

  def wo_total(_project, _office)
    woi_total(_project, _office).first.woi_t.to_s.to_d + wos_total(_project, _office).first.wos_t.to_s.to_d + wot_total(_project, _office).first.wot_t.to_s.to_d + wov_total(_project, _office).first.wov_t.to_s.to_d + wow_total(_project, _office).first.wow_t.to_s.to_d
  end

  def ii_total(_project, _office)
    if _office.nil?
      invoice_items.joins(invoice: :bill).where("bills.project_id in (?)",_project).select('SUM(invoice_items.quantity * (invoice_items.price - invoice_items.discount)) ii_t')
    else
      invoice_items.joins(invoice: [bill: :project]).where("projects.office_id = ?",_office).where("bills.project_id in (?) AND projects.office_id = ?",_project, _office).select('SUM(invoice_items.quantity * (invoice_items.price - invoice_items.discount)) ii_t')
    end
  end

  # total cost and price for reports whit date
  def dni_total_date(_project, _from, _to, _office)
    if _office.nil?
      delivery_note_items.joins(:delivery_note).where("delivery_notes.project_id in (?) AND delivery_notes.delivery_date >= ? AND delivery_notes.delivery_date <= ?",_project,_from,_to).select('SUM(delivery_note_items.quantity * delivery_note_items.cost) dni_t')
    else
      delivery_note_items.joins(:delivery_note,:project).where("delivery_notes.project_id in (?) AND delivery_notes.delivery_date >= ? AND delivery_notes.delivery_date <= ? AND projects.office_id = ?",_project,_from,_to, _office).select('SUM(delivery_note_items.quantity * delivery_note_items.cost) dni_t')
    end
  end

  def oi_total_date(_project, _from, _to, _office)
    if _office.nil?
      offer_items.joins(:offer).where("offers.project_id in (?) AND offers.offer_date >= ? AND offers.offer_date <= ?",_project,_from,_to).select('SUM(offer_items.quantity * (offer_items.price - offer_items.discount)) oi_t')
    else
      offer_items.joins(:offer,:project).where("offers.project_id in (?) AND offers.offer_date >= ? AND offers.offer_date <= ? AND projects.office_id = ?",_project,_from,_to, _office).select('SUM(offer_items.quantity * (offer_items.price - offer_items.discount)) oi_t')
    end
  end

  def ori_total_date(_project, _from, _to, _office)
    if _office.nil?
      offer_request_items.joins(:offer_request).where("offer_requests.project_id in (?) AND offer_requests.request_date >= ? AND offer_requests.request_date <= ?",_project,_from,_to).select('SUM(offer_request_items.quantity * offer_request_items.price) ori_t')
    else
      offer_request_items.joins(:offer_request,:project).where("offer_requests.project_id in (?) AND offer_requests.request_date >= ? AND offer_requests.request_date <= ? AND projects.office_id = ?",_project,_from,_to, _office).select('SUM(offer_request_items.quantity * offer_request_items.price) ori_t')
    end
  end

  def poi_total_date(_project, _from, _to, _office)
    if _office.nil?
      purchase_order_items.joins(:purchase_order).where("purchase_orders.project_id in (?) AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ?",_project,_from,_to).select('SUM(purchase_order_items.quantity * (purchase_order_items.price - purchase_order_items.discount)) poi_t')
    else
      purchase_order_items.joins(:purchase_order,:project).where("purchase_orders.project_id in (?) AND purchase_orders.order_date >= ? AND purchase_orders.order_date <= ? AND projects.office_id = ?",_project,_from,_to, _office).select('SUM(purchase_order_items.quantity * (purchase_order_items.price - purchase_order_items.discount)) poi_t')
    end
  end

  def rni_total_date(_project, _from, _to, _office)
    if _office.nil?
      receipt_note_items.joins(:receipt_note).where("receipt_notes.project_id in (?) AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ?",_project,_from,_to).select('SUM(receipt_note_items.quantity * (receipt_note_items.price - receipt_note_items.discount)) rni_t')
    else
      receipt_note_items.joins(:receipt_note,:project).where("receipt_notes.project_id in (?) AND receipt_notes.receipt_date >= ? AND receipt_notes.receipt_date <= ? AND projects.office_id = ?",_project,_from,_to, _office).select('SUM(receipt_note_items.quantity * (receipt_note_items.price - receipt_note_items.discount)) rni_t')
    end
  end

  def soi_total_date(_project, _from, _to, _office)
    if _office.nil?
      sale_offer_items.joins(:sale_offer).where("sale_offers.project_id in (?) AND sale_offers.offer_date >= ? AND sale_offers.offer_date <= ?",_project,_from,_to).select('SUM(sale_offer_items.quantity * (sale_offer_items.price - sale_offer_items.discount)) soi_t')
    else
      sale_offer_items.joins(:sale_offer,:project).where("sale_offers.project_id in (?) AND sale_offers.offer_date >= ? AND sale_offers.offer_date <= ? AND projects.office_id = ?",_project,_from,_to, _office).select('SUM(sale_offer_items.quantity * (sale_offer_items.price - sale_offer_items.discount)) soi_t')
    end
  end

  def sii_total_date(_project, _from, _to, _office)
    if _office.nil?
      supplier_invoice_items.joins(:supplier_invoice).where("supplier_invoices.project_id in (?) AND supplier_invoices.invoice_date >= ? AND supplier_invoices.invoice_date <= ?",_project,_from,_to).select('SUM(supplier_invoice_items.quantity * (supplier_invoice_items.price - supplier_invoice_items.discount)) sii_t')
    else
      supplier_invoice_items.joins(:supplier_invoice,:project).where("supplier_invoices.project_id in (?) AND supplier_invoices.invoice_date >= ? AND supplier_invoices.invoice_date <= ? AND projects.office_id = ?",_project,_from,_to, _office).select('SUM(supplier_invoice_items.quantity * (supplier_invoice_items.price - supplier_invoice_items.discount)) sii_t')
    end
  end

  def woi_total_date(_project, _from, _to, _office)
    if _office.nil?
      work_order_items.joins(:work_order).where("work_orders.project_id in (?) AND work_orders.created_at >= ? AND work_orders.created_at <= ?",_project,_from,_to).select('SUM(work_order_items.quantity * work_order_items.cost) woi_t')
    else
      work_order_items.joins(work_order: :project).where("work_orders.project_id in (?) AND work_orders.created_at >= ? AND work_orders.created_at <= ? AND projects.office_id = ?",_project,_from,_to, _office).select('SUM(work_order_items.quantity * work_order_items.cost) woi_t')
    end
  end

  def wos_total_date(_project, _from, _to, _office)
    # work_order_subcontractors.sum(&:cost)
    if _office.nil?
      work_order_subcontractors.joins(:work_order).where("work_orders.project_id in (?) AND work_orders.created_at >= ? AND work_orders.created_at <= ?",_project,_from,_to).joins(purchase_order: :purchase_order_items).select('SUM((purchase_order_items.quantity * (purchase_order_items.price - purchase_order_items.discount)) - ((purchase_order_items.discount_pct / 100) * (purchase_order_items.quantity * (purchase_order_items.price - purchase_order_items.discount)) - purchase_order_items.discount )) wos_t ')
    else
      work_order_subcontractors.joins(work_order: :project).where("work_orders.project_id in (?) AND work_orders.created_at >= ? AND work_orders.created_at <= ? AND projects.office_id = ?",_project,_from,_to, _office).joins(purchase_order: :purchase_order_items).select('SUM((purchase_order_items.quantity * (purchase_order_items.price - purchase_order_items.discount)) - ((purchase_order_items.discount_pct / 100) * (purchase_order_items.quantity * (purchase_order_items.price - purchase_order_items.discount)) - purchase_order_items.discount )) wos_t ')
    end
  end

  def wot_total_date(_project, _from, _to, _office)
    if _office.nil?
      work_order_tools.joins(:work_order).where("work_orders.project_id in (?) AND work_orders.created_at >= ? AND work_orders.created_at <= ?",_project,_from,_to).select('SUM(work_order_tools.minutes * work_order_tools.cost) wot_t')
    else
      work_order_tools.joins(work_order: :project).where("work_orders.project_id in (?) AND work_orders.created_at >= ? AND work_orders.created_at <= ? AND projects.office_id = ?",_project,_from,_to, _office).select('SUM(work_order_tools.minutes * work_order_tools.cost) wot_t')
    end
  end

  def wov_total_date(_project, _from, _to, _office)
    if _office.nil?
      work_order_vehicles.joins(:work_order).where("work_orders.project_id in (?) AND work_orders.created_at >= ? AND work_orders.created_at <= ?",_project,_from,_to).select('SUM(work_order_vehicles.distance * work_order_vehicles.cost) wov_t')
    else
      work_order_vehicles.joins(work_order: :project).where("work_orders.project_id in (?) AND work_orders.created_at >= ? AND work_orders.created_at <= ? AND projects.office_id = ?",_project,_from,_to, _office).select('SUM(work_order_vehicles.distance * work_order_vehicles.cost) wov_t')
    end
  end

  def wow_total_date(_project, _from, _to, _office)
    if _office.nil?
      work_order_workers.joins(:work_order).where("work_orders.project_id in (?) AND work_orders.created_at >= ? AND work_orders.created_at <= ?",_project,_from,_to).select('SUM(work_order_workers.hours * work_order_workers.cost) wow_t')
    else
      work_order_workers.joins(work_order: :project).where("work_orders.project_id in (?) AND work_orders.created_at >= ? AND work_orders.created_at <= ? AND projects.office_id = ?",_project,_from,_to, _office).select('SUM(work_order_workers.hours * work_order_workers.cost) wow_t')
    end
  end

  def wo_total_date(_project, _from, _to, _office)
    woi_total_date(_project, _from, _to, _office).first.woi_t.to_s.to_d + wos_total_date(_project, _from, _to, _office).first.wos_t.to_s.to_d + wot_total_date(_project, _from, _to, _office).first.wot_t.to_s.to_d + wov_total_date(_project, _from, _to, _office).first.wov_t.to_s.to_d + wow_total_date(_project, _from, _to, _office).first.wow_t.to_s.to_d
  end

  def ii_total_date(_project, _from, _to, _office)
    if _office.nil?
      invoice_items.joins(invoice: :bill).where("bills.project_id in (?) AND invoices.invoice_date >= ? AND invoices.invoice_date <= ?",_project,_from,_to).select('SUM(invoice_items.quantity * (invoice_items.price - invoice_items.discount)) ii_t')
    else
      invoice_items.joins(invoice: [bill: :project]).where("projects.office_id = ?",_office).where("bills.project_id in (?) AND invoices.invoice_date >= ? AND invoices.invoice_date <= ?",_project,_from,_to).select('SUM(invoice_items.quantity * (invoice_items.price - invoice_items.discount)) ii_t')
    end
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
