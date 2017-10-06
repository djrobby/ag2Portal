class PurchaseOrder < ActiveRecord::Base
  include ModelsModule

  belongs_to :offer, :counter_cache => true
  belongs_to :supplier
  belongs_to :payment_method
  belongs_to :order_status
  belongs_to :project
  belongs_to :store
  belongs_to :work_order
  belongs_to :charge_account
  belongs_to :organization
  belongs_to :approver, class_name: 'User'
  belongs_to :petitioner, class_name: 'User', foreign_key: 'created_by'
  attr_accessible :discount, :discount_pct, :order_date, :order_no, :remarks, :supplier_offer_no,
                  :supplier_id, :payment_method_id, :order_status_id, :project_id, :offer_id,
                  :store_id, :work_order_id, :charge_account_id, :retention_pct, :retention_time,
                  :organization_id, :approver_id, :approval_date,
                  :store_address_1, :store_address_2, :store_phones, :created_by, :totals
  attr_accessible :purchase_order_items_attributes

  has_many :purchase_order_items, dependent: :destroy
  has_many :purchase_order_item_balances, through: :purchase_order_items
  has_many :purchase_order_item_invoiced_balances, through: :purchase_order_items
  has_many :products, through: :purchase_order_items
  has_many :receipt_notes
  has_many :receipt_note_items
  has_many :supplier_invoices
  has_many :supplier_invoice_items

  # Nested attributes
  accepts_nested_attributes_for :purchase_order_items,
                                :reject_if => :all_blank,
                                :allow_destroy => true
  has_paper_trail

  validates_associated :purchase_order_items

  validates :order_date,      :presence => true
  validates :order_no,        :presence => true,
                              :length => { :is => 22 },
                              :format => { with: /\A[a-zA-Z\d]+\Z/, message: :code_invalid },
                              :uniqueness => { :scope => :organization_id }
  validates :supplier,        :presence => true
  validates :payment_method,  :presence => true
  validates :order_status,    :presence => true
  validates :project,         :presence => true
  validates :organization,    :presence => true

  # Scopes
  scope :by_no, -> { order(:order_no) }
  scope :by_supplier_no, -> { order(:supplier_id, :order_no) }
  #
  scope :these, -> t { where(id: t).by_no }
  scope :with_supplier, -> { includes(:supplier).by_supplier_no }
  scope :belongs_to_organization, -> o { includes(:supplier).where("organization_id = ?", o).by_supplier_no }
  scope :belongs_to_supplier, -> s { includes(:supplier).where("supplier_id = ?", s).by_supplier_no }
  scope :belongs_to_organization_supplier, -> o,s { includes(:supplier).where("organization_id = ? AND supplier_id = ?", o, s).by_supplier_no }
  scope :belongs_to_organization_project, -> o,p { includes(:supplier).where("organization_id = ? AND project_id = ?", o, p).by_supplier_no }
  scope :belongs_to_organization_project_supplier, -> o,p,s { includes(:supplier).where("organization_id = ? AND project_id = ? AND supplier_id = ?", o, p, s).by_supplier_no }
  scope :belongs_to_project_supplier, -> p,s { includes(:supplier).where("project_id = ? AND supplier_id = ?", p, s).by_supplier_no }

  # Callbacks
  before_destroy :check_for_dependent_records
  before_save :calculate_and_store_totals
  after_create :notify_on_create
  after_update :notify_on_update
  after_save :reindex
  after_destroy :reindex

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = full_no
    if !self.order_date.blank?
      full_name += " " + formatted_date(self.order_date)
    end
    if !self.supplier.blank?
      full_name += " " + self.supplier.full_name
    end
    full_name
  end

  def partial_name
    partial_name = full_no
    if !self.supplier.blank?
      partial_name += " " + self.supplier.name[0,40]
    end
    partial_name
  end

  def full_no
    # Order no (Project code & year & sequential number) => PPPPPPPPPPPP-YYYY-NNNNNN
    order_no.blank? ? "" : order_no[0..11] + '-' + order_no[12..15] + '-' + order_no[16..21]
  end

  #
  # Calculated fields
  #
  def subtotal
    purchase_order_items.reject(&:marked_for_destruction?).sum(&:amount)
  end

  def bonus
    (discount_pct / 100) * subtotal if !discount_pct.blank?
  end

  def taxable
    subtotal - bonus - discount
  end

  def taxes
    purchase_order_items.reject(&:marked_for_destruction?).sum(&:net_tax)
  end

  def total
    taxable + taxes
  end

  def balance
    purchase_order_item_balances.sum(:balance)
  end

  def unbilled_balance
    purchase_order_item_invoiced_balances.sum(:balance)
  end

  def quantity
    purchase_order_items.sum(:quantity)
  end

  def delivery_avg
    avg, cnt = 0, 0
    purchase_order_items.each do |i|
      if !i.delivery_date.blank?
        avg += Time.parse(i.delivery_date.to_s).to_f
        cnt += 1
      end
    end
    cnt > 0 ? Date.parse(Time.at(avg / cnt).to_s) : nil
  end

  def offer_no
    offer.nil? ? nil : offer.offer_no
  end

  # Returns multidimensional array containing different tax type in each line
  # Each line contains 5 elements: Id, Description, Tax %, Net amount & Net tax
  def tax_breakdown
    global_tax_breakdown(purchase_order_items, true)
  end

  # Reception status based on current balance
  def reception_status
    if balance <= 0           # fully received
      _status = I18n.t("activerecord.attributes.purchase_order.reception_status_total")
    elsif balance == quantity # unreceived
      _status = I18n.t("activerecord.attributes.purchase_order.reception_status_unreceived")
    else                      # partially received
      _status = I18n.t("activerecord.attributes.purchase_order.reception_status_partial")
    end
    _status
  end
  def reception_status_id
    if balance <= 0           # 0
      _status = 0
    elsif balance == quantity # 2
      _status = 2
    else                      # 1
      _status = 1
    end
    _status
  end

  #
  # Class (self) user defined methods
  #
  def self.petitioners
    User.where(id: PurchaseOrder.joins(:petitioner).group(:created_by).select('purchase_orders.created_by'))
  end

  def self.undelivered(organization = nil, _ordered = true)
    if !organization.blank?
      if !_ordered
        includes(:supplier).joins(:purchase_order_item_balances).where('NOT purchase_orders.approver_id IS NULL AND purchase_orders.organization_id = ?', organization).group('purchase_orders.id').having('sum(purchase_order_item_balances.balance) > ?', 0)
      else
        includes(:supplier).joins(:purchase_order_item_balances).where('NOT purchase_orders.approver_id IS NULL AND purchase_orders.organization_id = ?', organization).group('purchase_orders.supplier_id, purchase_orders.order_no, purchase_orders.id').having('sum(purchase_order_item_balances.balance) > ?', 0)
      end
    else
      if !_ordered
        includes(:supplier).joins(:purchase_order_item_balances).where('NOT purchase_orders.approver_id IS NULL').group('purchase_orders.id').having('sum(purchase_order_item_balances.balance) > ?', 0)
      else
        includes(:supplier).joins(:purchase_order_item_balances).where('NOT purchase_orders.approver_id IS NULL').group('purchase_orders.supplier_id, purchase_orders.order_no, purchase_orders.id').having('sum(purchase_order_item_balances.balance) > ?', 0)
      end
    end
  end

  def self.undelivered_by_project(_projects = nil, organization = nil, _ordered = true)
    if _projects.blank?
      PurchaseOrder.undelivered(organization, _ordered)
    else
      includes(:supplier).joins(:purchase_order_item_balances).where('NOT purchase_orders.approver_id IS NULL AND purchase_orders.project_id IN (?)', _projects).group('purchase_orders.supplier_id, purchase_orders.order_no, purchase_orders.id').having('sum(purchase_order_item_balances.balance) > ?', 0)
    end
  end

  def self.undelivered_by_company(s = nil, _ordered)
    if !_ordered
      includes(:supplier, :project).joins(:purchase_order_item_balances).where('NOT purchase_orders.approver_id IS NULL AND projects.company_id = ?', s).group('purchase_orders.supplier_id, purchase_orders.order_no, purchase_orders.id').having('sum(purchase_order_item_balances.balance) > ?', 0)
    else
      includes(:supplier, :project).joins(:purchase_order_item_balances).where('NOT purchase_orders.approver_id IS NULL AND projects.company_id = ?', s).group('purchase_orders.id').having('sum(purchase_order_item_balances.balance) > ?', 0)
    end
  end

  def self.undelivered_by_office(s = nil, _ordered)
    if !_ordered
      includes(:supplier, :project).joins(:purchase_order_item_balances).where('NOT purchase_orders.approver_id IS NULL AND projects.office_id = ?', s).group('purchase_orders.supplier_id, purchase_orders.order_no, purchase_orders.id').having('sum(purchase_order_item_balances.balance) > ?', 0)
    else
      includes(:supplier, :project).joins(:purchase_order_item_balances).where('NOT purchase_orders.approver_id IS NULL AND projects.office_id = ?', s).group('purchase_orders.id').having('sum(purchase_order_item_balances.balance) > ?', 0)
    end
  end

  ###
  # Unbilled purchase orders without receipt notes
  # (can't bill an already delivered (receipt note exists) purchase order!)
  #
  def self.without_receipt_notes
    joins('LEFT JOIN receipt_notes ON purchase_orders.id=receipt_notes.purchase_order_id').where('receipt_notes.purchase_order_id IS NULL')
  end

  def self.without_receipt_notes_and_approved
    joins('LEFT JOIN receipt_notes ON purchase_orders.id=receipt_notes.purchase_order_id').where('receipt_notes.purchase_order_id IS NULL AND NOT purchase_orders.approver_id IS NULL')
  end

  # One parameter at a time only
  def self.unbilled_and_undelivered(_organization=nil, _company=nil, _office=nil, _project=nil)
    if !_organization.blank?
      without_receipt_notes.includes(:supplier).joins(:purchase_order_item_invoiced_balances).where('purchase_orders.organization_id = ?', _organization).group('purchase_orders.supplier_id, purchase_orders.order_no, purchase_orders.id').having('sum(purchase_order_item_invoiced_balances.balance) > ?', 0)
    elsif !_company.blank?
      without_receipt_notes.includes(:supplier, :project).joins(:purchase_order_item_invoiced_balances).where('projects.company_id = ?', _company).group('purchase_orders.supplier_id, purchase_orders.order_no, purchase_orders.id').having('sum(purchase_order_item_invoiced_balances.balance) > ?', 0)
    elsif !_office.blank?
      without_receipt_notes.includes(:supplier, :project).joins(:purchase_order_item_invoiced_balances).where('projects.office_id = ?', _office).group('purchase_orders.supplier_id, purchase_orders.order_no, purchase_orders.id').having('sum(purchase_order_item_invoiced_balances.balance) > ?', 0)
    elsif !_project.blank?
      without_receipt_notes.includes(:supplier, :project).joins(:purchase_order_item_invoiced_balances).where('purchase_orders.project_id = ?',_project).group('purchase_orders.supplier_id, purchase_orders.order_no, purchase_orders.id').having('sum(purchase_order_item_invoiced_balances.balance) > ?', 0)
    else
      without_receipt_notes
    end
  end

  def self.approved_unbilled_and_undelivered(_organization=nil, _company=nil, _office=nil, _project=nil)
    if !_organization.blank?
      without_receipt_notes_and_approved.includes(:supplier).joins(:purchase_order_item_invoiced_balances).where('purchase_orders.organization_id = ?', _organization).group('purchase_orders.supplier_id, purchase_orders.order_no, purchase_orders.id').having('sum(purchase_order_item_invoiced_balances.balance) > ?', 0)
    elsif !_company.blank?
      without_receipt_notes_and_approved.includes(:supplier, :project).joins(:purchase_order_item_invoiced_balances).where('projects.company_id = ?', _company).group('purchase_orders.supplier_id, purchase_orders.order_no, purchase_orders.id').having('sum(purchase_order_item_invoiced_balances.balance) > ?', 0)
    elsif !_office.blank?
      without_receipt_notes_and_approved.includes(:supplier, :project).joins(:purchase_order_item_invoiced_balances).where('projects.office_id = ?', _office).group('purchase_orders.supplier_id, purchase_orders.order_no, purchase_orders.id').having('sum(purchase_order_item_invoiced_balances.balance) > ?', 0)
    elsif !_project.blank?
      without_receipt_notes_and_approved.includes(:supplier, :project).joins(:purchase_order_item_invoiced_balances).where('purchase_orders.project_id = ?',_project).group('purchase_orders.supplier_id, purchase_orders.order_no, purchase_orders.id').having('sum(purchase_order_item_invoiced_balances.balance) > ?', 0)
    else
      without_receipt_notes_and_approved
    end
  end

  def self.unbilled(organization, _ordered)
    if !organization.blank?
      if !_ordered
        includes(:supplier).joins(:purchase_order_item_invoiced_balances).where('purchase_orders.organization_id = ?', organization).group('purchase_orders.id').having('sum(purchase_order_item_invoiced_balances.balance) > ?', 0)
      else
        includes(:supplier).joins(:purchase_order_item_invoiced_balances).where('purchase_orders.organization_id = ?', organization).group('purchase_orders.supplier_id, purchase_orders.order_no, purchase_orders.id').having('sum(purchase_order_item_invoiced_balances.balance) > ?', 0)
      end
    else
      if !_ordered
        includes(:supplier).joins(:purchase_order_item_invoiced_balances).group('purchase_orders.id').having('sum(purchase_order_item_invoiced_balances.balance) > ?', 0)
      else
        includes(:supplier).joins(:purchase_order_item_invoiced_balances).group('purchase_orders.supplier_id, purchase_orders.order_no, purchase_orders.id').having('sum(purchase_order_item_invoiced_balances.balance) > ?', 0)
      end
    end
  end

  def self.unbilled_by_project(_project = nil, _ordered = true)
    if !_ordered
      includes(:supplier, :project).joins(:purchase_order_item_invoiced_balances).where('purchase_orders.project_id = ?',_project).group('purchase_orders.id').having('sum(purchase_order_item_invoiced_balances.balance) > ?', 0)
    else
      includes(:supplier, :project).joins(:purchase_order_item_invoiced_balances).where('purchase_orders.project_id = ?',_project).group('purchase_orders.supplier_id, purchase_orders.order_no, purchase_orders.id').having('sum(purchase_order_item_invoiced_balances.balance) > ?', 0)
    end
  end

  def self.unbilled_by_project_supplier(_project = nil, _supplier = nil, _ordered = true)
    if !_ordered
      includes(:supplier, :project).joins(:purchase_order_item_invoiced_balances).where('purchase_orders.project_id = ? AND purchase_orders.supplier_id = ?', _project, _supplier).group('purchase_orders.id').having('sum(purchase_order_item_invoiced_balances.balance) > ?', 0)
    else
      includes(:supplier, :project).joins(:purchase_order_item_invoiced_balances).where('purchase_orders.project_id = ? AND purchase_orders.supplier_id = ?', _project, _supplier).group('purchase_orders.supplier_id, purchase_orders.order_no, purchase_orders.id').having('sum(purchase_order_item_invoiced_balances.balance) > ?', 0)
    end
  end

  def self.unbilled_by_projects(_projects = nil, organization = nil, _ordered = true)
    if _projects.blank?
      PurchaseOrder.unbilled(organization, _ordered)
    else
      includes(:supplier).joins(:purchase_order_item_invoiced_balances).where('purchase_orders.project_id IN (?)', _projects).group('purchase_orders.supplier_id, purchase_orders.order_no, purchase_orders.id').having('sum(purchase_order_item_invoiced_balances.balance) > ?', 0)
    end
  end

  def self.unbilled_by_company(s = nil, _ordered)
    if !_ordered
      includes(:supplier, :project).joins(:purchase_order_item_invoiced_balances).where('projects.company_id = ?', s).group('purchase_orders.id').having('sum(purchase_order_item_invoiced_balances.balance) > ?', 0)
    else
      includes(:supplier, :project).joins(:purchase_order_item_invoiced_balances).where('projects.company_id = ?', s).group('purchase_orders.supplier_id, purchase_orders.order_no, purchase_orders.id').having('sum(purchase_order_item_invoiced_balances.balance) > ?', 0)
    end
  end

  def self.unbilled_by_office(s = nil, _ordered)
    if !_ordered
      includes(:supplier, :project).joins(:purchase_order_item_invoiced_balances).where('projects.office_id = ?', s).group('purchase_orders.id').having('sum(purchase_order_item_invoiced_balances.balance) > ?', 0)
    else
      includes(:supplier, :project).joins(:purchase_order_item_invoiced_balances).where('projects.office_id = ?', s).group('purchase_orders.supplier_id, purchase_orders.order_no, purchase_orders.id').having('sum(purchase_order_item_invoiced_balances.balance) > ?', 0)
    end
  end

  def self.approved(organization, _ordered)
    if !organization.blank?
      if !_ordered
        where('purchase_orders.organization_id = ? AND NOT purchase_orders.approver_id IS NULL', organization).order('purchase_orders.id')
      else
        where('purchase_orders.organization_id = ? AND NOT purchase_orders.approver_id IS NULL', organization).order('purchase_orders.supplier_id, purchase_orders.order_no, purchase_orders.id')
      end
    else
      if !_ordered
        where('NOT purchase_orders.approver_id IS NULL').order('purchase_orders.id')
      else
        where('NOT purchase_orders.approver_id IS NULL').order('purchase_orders.supplier_id, purchase_orders.order_no, purchase_orders.id')
      end
    end
  end

  # Orders which include product family (and projects)
  def self.has_family(_family, _projects)
    if !_projects.blank?
      joins(:purchase_order_items, :products).where("products.product_family_id = ? AND purchase_orders.project_id IN (?)", _family, _projects).group('purchase_orders.id')
    else
      joins(:purchase_order_items, :products).where("products.product_family_id = ?", _family).group('purchase_orders.id')
    end
  end

  # Orders which include product (and projects)
  def self.has_product(_product, _projects)
    if !_projects.blank?
      joins(:purchase_order_items).where("purchase_order_items.product_id = ? AND purchase_orders.project_id IN (?)", _product, _projects).group('purchase_orders.id')
    else
      joins(:purchase_order_items).where("purchase_order_items.product_id = ?", _product).group('purchase_orders.id')
    end
  end

  # Orders with pending balance (and projects)
  def self.pending_balance(_projects = nil)
    if !_projects.blank?
      joins(:purchase_order_item_balances).where("purchase_orders.project_id IN (?)", _projects).group('purchase_orders.id').having('sum(purchase_order_item_balances.balance) > ?', 0)
    else
      joins(:purchase_order_item_balances).group('purchase_orders.id').having('sum(purchase_order_item_balances.balance) > ?', 0)
    end
  end

  #
  # Records navigator
  #
  def to_first
    PurchaseOrder.order("order_no desc").first
  end

  def to_prev
    PurchaseOrder.where("order_no > ?", order_no).order("order_no desc").last
  end

  def to_next
    PurchaseOrder.where("order_no < ?", order_no).order("order_no desc").first
  end

  def to_last
    PurchaseOrder.order("order_no desc").last
  end

  searchable do
    text :order_no, :supplier_offer_no
    integer :id, :multiple => true          # Multiple search values accepted in one search (current_projects)
    string :order_no, :multiple => true     # Multiple search values accepted in one search (inverse_no_search)
    integer :supplier_id
    integer :payment_method_id
    integer :order_status_id
    integer :project_id, :multiple => true  # Multiple search values accepted in one search (current_projects)
    integer :store_id
    integer :work_order_id
    integer :charge_account_id
    integer :offer_id
    date :order_date
    integer :organization_id
    integer :created_by
    integer :reception_status_id
    float :quantity
    float :balance
    string :sort_no do
      order_no
    end
  end

  private

  def calculate_and_store_totals
    self.totals = total
  end

  def reindex
    Sunspot.index(self)
  end

  # Before destroy
  def check_for_dependent_records
    # Check for receipt notes
    if receipt_notes.count > 0
      errors.add(:base, I18n.t('activerecord.models.purchase_order.check_for_receipt_notes'))
      return false
    end
    # Check for receipt note items
    if receipt_note_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.purchase_order.check_for_receipt_notes'))
      return false
    end
  end

  #
  # Notifiers
  #
  # After create
  def notify_on_create
    # Always notify on create
    Notifier.purchase_order_saved(self, 1).deliver
    if check_if_approval_is_required
      Notifier.purchase_order_saved_with_approval(self, 1).deliver
    end
  end

  # After update
  def notify_on_update
    # Notify only if key values changed
    items_changed = false
    purchase_order_items.each do |i|
      if i.changed?
        items_changed = true
        break
      end
    end
    if self.changed? || items_changed
      Notifier.purchase_order_saved(self, 3).deliver
      if check_if_approval_is_required
        Notifier.purchase_order_saved_with_approval(self, 3).deliver
      end
    end
  end

  #
  # Helper methods for notifiers
  #
  # Need approval?
  def check_if_approval_is_required
    check_by_families || check_by_supplier || check_by_project ||
    check_by_office || check_by_company || check_by_zone
  end

  # Maximums by product family
  # (quantity & net amount)
  # Returns true if approval is required, otherwise false
  def check_by_families
    _r = false
    # global_family_breakdown returns multidimensional array containing different product family in each line
    # Each line contains 5 elements: Family Id, max_orders_count, max_orders_sum, Quantity sum & Net amount sum
    a = global_family_breakdown(purchase_order_items.joins(:product).order(:product_family_id))
    d = a.detect { |f| (f[1] > 0 && (f[3] > f[1])) || (f[2] > 0 && (f[4] > f[2])) }
    _r = d.nil? ? false : true
  end

  # Maximums by supplier
  # (quantity & taxable)
  # Returns true if approval is required, otherwise false
  def check_by_supplier
    _r = false
    c = self.supplier.max_orders_count.blank? ? 0 : self.supplier.max_orders_count
    s = self.supplier.max_orders_sum.blank? ? 0 : self.supplier.max_orders_sum
    _r = (c > 0 && (self.quantity > c)) || (s > 0 && (self.taxable > s))
  end

  # Maximums by project
  # (item net sum & item net price)
  # Returns true if approval is required, otherwise false
  def check_by_project
    _r = false
    # global_project_breakdown returns multidimensional array containing different project in each line
    # Each line contains 5 elements: Project Id, max_order_total, max_order_price, Net amount sum by project & Item net price
    a = global_project_breakdown(purchase_order_items.order(:project_id))
    d = a.detect { |f| (f[1] > 0 && (f[3] > f[1])) || (f[2] > 0 && (f[4] > f[2])) }
    _r = d.nil? ? false : true
  end

  # Maximums by office
  # (item net sum & item net price)
  # Returns true if approval is required, otherwise false
  def check_by_office
    _r = false
    # global_office_breakdown returns multidimensional array containing different office in each line
    # Each line contains 5 elements: Office Id, max_order_total, max_order_price, Net amount sum by project & Item net price
    a = global_office_breakdown(purchase_order_items.joins(:project).order(:office_id))
    d = a.detect { |f| (f[1] > 0 && (f[3] > f[1])) || (f[2] > 0 && (f[4] > f[2])) }
    _r = d.nil? ? false : true
  end

  # Maximums by company
  # (item net sum & item net price)
  # Returns true if approval is required, otherwise false
  def check_by_company
    _r = false
    # global_company_breakdown returns multidimensional array containing different company in each line
    # Each line contains 5 elements: Company Id, max_order_total, max_order_price, Net amount sum by project & Item net price
    a = global_company_breakdown(purchase_order_items.joins(:project).order(:company_id))
    d = a.detect { |f| (f[1] > 0 && (f[3] > f[1])) || (f[2] > 0 && (f[4] > f[2])) }
    _r = d.nil? ? false : true
  end

  # Maximums by zone
  # (item net sum & item net price)
  # Returns true if approval is required, otherwise false
  def check_by_zone
    _r = false
    # global_zone_breakdown returns multidimensional array containing different zone in each line
    # Each line contains 5 elements: Zone Id, max_order_total, max_order_price, Net amount sum by project & Item net price
    a = global_zone_breakdown(purchase_order_items.joins(project: :office).order(:zone_id))
    d = a.detect { |f| (f[1] > 0 && (f[3] > f[1])) || (f[2] > 0 && (f[4] > f[2])) }
    _r = d.nil? ? false : true
  end
end
