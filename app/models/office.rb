class Office < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_offices
  belongs_to :company
  belongs_to :province
  belongs_to :town
  belongs_to :zipcode
  belongs_to :street_type
  belongs_to :zone
  belongs_to :water_supply_contract_template, class_name: "ContractTemplate", foreign_key: "water_supply_contract_template_id"
  belongs_to :water_connection_contract_template, class_name: "ContractTemplate", foreign_key: "water_connection_contract_template_id"

  attr_accessible :name, :company_id, :office_code, :zone_id,
                  :street_type_id, :street_name, :street_number, :building, :floor, :floor_office,
                  :zipcode_id, :town_id, :province_id, :phone, :fax, :cellular, :email,
                  :created_by, :updated_by, :nomina_id, :max_order_total, :max_order_price, :overtime_pct,
                  :r_last_name, :r_first_name, :r_fiscal_id, :r_position, :days_for_invoice_due_date,
                  :water_supply_contract_template_id, :water_connection_contract_template_id
  attr_accessible :office_notifications_attributes

  has_many :workers
  has_many :worker_items
  has_many :corp_contacts, :order => 'last_name, first_name'
  has_many :tickets
  has_many :projects
  has_many :office_notifications, dependent: :destroy
  has_many :infrastructures
  has_many :meters
  has_many :subscribers
  has_many :service_points
  has_many :invoice_current_debts
  # MJ
  has_many :charge_accounts, through: :projects
  has_many :delivery_note_items, through: :projects
  has_many :offer_items, through: :projects
  has_many :offer_request_items, through: :projects
  has_many :purchase_orders, through: :projects
  has_many :purchase_order_items, through: :projects
  has_many :receipt_note_items, through: :projects
  has_many :sale_offer_items, through: :projects
  has_many :supplier_invoice_items, through: :projects
  has_many :work_orders, through: :projects
  has_many :work_order_items, through: :projects
  has_many :work_order_subcontractors, through: :projects
  has_many :work_order_tools, through: :projects
  has_many :work_order_vehicles, through: :projects
  has_many :work_order_workers, through: :projects
  has_many :invoice_items, through: :projects
  has_many :delivery_note_items, through: :projects

  # Nested attributes
  accepts_nested_attributes_for :office_notifications,
                                :reject_if => :all_blank,
                                :allow_destroy => true

  has_paper_trail

  validates :name,         :presence => true
  validates :company,      :presence => true
  validates :office_code,  :presence => true,
                           :length => { :minimum => 5, :maximum => 8 },
                           :uniqueness => true
  validates :street_type,  :presence => true
  validates :zipcode,      :presence => true
  validates :town,         :presence => true
  validates :province,     :presence => true

  before_destroy :check_for_dependent_records

  def to_label
    "#{name} (#{company.name})"
  end

  def address_1
    _ret = ""
    if !street_type.blank?
      _ret += street_type.street_type_code.titleize + ". "
    end
    if !street_name.blank?
      _ret += street_name + " "
    end
    if !street_number.blank?
      _ret += street_number + ", "
    end
    if !building.blank?
      _ret += building.titleize + ", "
    end
    if !floor.blank?
      _ret += floor_human + " "
    end
    if !floor_office.blank?
      _ret += floor_office
    end
    _ret
  end

  def address_2
    _ret = ""
    if !zipcode.blank?
      _ret += zipcode.zipcode + " "
    end
    if !town.blank?
      _ret += town.name + ", "
    end
    if !province.blank?
      _ret += province.name + " "
      if !province.region.country.blank?
        _ret += "(" + province.region.country.name + ")"
      end
    end
    _ret
  end

  def floor_human
    _ret = floor
    _floor_is_numeric = true if Float(floor) rescue false
    if _floor_is_numeric
      _ret = floor.strip + "\xBA".force_encoding('ISO-8859-1').encode('UTF-8')
    end
    _ret
  end

  def phone_fax_email
    _ret = ""
    if !self.phone.blank?
      _ret += I18n.t("activerecord.attributes.office.phone_c") + ": " + self.phone.strip
    end
    if !self.fax.blank?
      _ret += _ret.blank? ? I18n.t("activerecord.attributes.office.fax") + ": " + self.fax.strip : " / " + I18n.t("activerecord.attributes.office.fax") + ": " + self.fax.strip
    end
    if !self.email.blank?
      _ret += _ret.blank? ? self.email.strip : " / " + self.email.strip
    end
    _ret
  end

  def r_full_name
    full_name = ""
    if !self.r_last_name.blank?
      full_name += self.r_last_name
    end
    if !self.r_first_name.blank?
      full_name += ", " + self.r_first_name
    end
    full_name[0,40]
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

  searchable do
    text :office_code, :name
    string :office_code
    integer :town_id
    integer :province_id
    integer :company_id
    integer :organization_id do
      company.organization_id unless (company.blank? || company.organization_id.blank?)
    end
    text :company_name do
      company.name unless (company.blank? || company.name.blank?)
    end
  end

  private

  def check_for_dependent_records
    # Check for workers
    if workers.count > 0
      errors.add(:base, I18n.t('activerecord.models.office.check_for_workers'))
      return false
    end
    # Check for worker items
    if worker_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.office.check_for_workers'))
      return false
    end
    # Check for corp contacts
    if corp_contacts.count > 0
      errors.add(:base, I18n.t('activerecord.models.office.check_for_contacts'))
      return false
    end
    # Check for projects
    if projects.count > 0
      errors.add(:base, I18n.t('activerecord.models.office.check_for_projects'))
      return false
    end
    # Check for tickets
    if tickets.count > 0
      errors.add(:base, I18n.t('activerecord.models.office.check_for_tickets'))
      return false
    end
  end
end
