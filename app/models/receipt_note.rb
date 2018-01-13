# encoding: utf-8

class ReceiptNote < ActiveRecord::Base
  include ModelsModule

  belongs_to :supplier
  belongs_to :payment_method
  belongs_to :project
  belongs_to :store
  belongs_to :work_order
  belongs_to :charge_account
  belongs_to :purchase_order
  belongs_to :organization
  attr_accessible :discount, :discount_pct, :receipt_date, :receipt_no, :remarks, :retention_pct, :retention_time,
                  :supplier_id, :payment_method_id, :project_id, :store_id, :work_order_id, :charge_account_id,
                  :purchase_order_id, :organization_id, :attachment, :totals
  attr_accessible :receipt_note_items_attributes
  has_attached_file :attachment, :styles => { :medium => "192x192>", :small => "128x128>" }, :default_url => "/images/missing/:style/attachment.png"

  has_many :receipt_note_items, dependent: :destroy
  has_many :receipt_note_item_balances, through: :receipt_note_items
  has_many :products, through: :receipt_note_items
  has_many :supplier_invoice_items

  # Nested attributes
  accepts_nested_attributes_for :receipt_note_items,
                                :reject_if => :all_blank,
                                :allow_destroy => true

  has_paper_trail

  validates_associated :receipt_note_items

  validates :receipt_date,    :presence => true
  validates :receipt_no,      :presence => true,
                              :uniqueness => { :scope => [ :organization_id, :supplier_id ] }
  validates :supplier,        :presence => true
  validates :payment_method,  :presence => true
  validates :project,         :presence => true
  validates :organization,    :presence => true

  # Scopes
  scope :by_no, -> { order(:receipt_no) }
  scope :by_supplier_no, -> { order(:supplier_id, :receipt_no) }
  #
  scope :these, -> t { where(id: t).by_no }
  scope :with_supplier, -> { includes(:supplier).by_supplier_no }
  scope :belongs_to_organization, -> o { includes(:supplier).where("organization_id = ?", o).by_supplier_no }
  scope :belongs_to_supplier, -> s { includes(:supplier).where("supplier_id = ?", s).by_supplier_no }
  scope :belongs_to_organization_supplier, -> o,s { includes(:supplier).where("organization_id = ? AND supplier_id = ?", o, s).by_supplier_no }
  scope :belongs_to_organization_project, -> o,p { includes(:supplier).where("organization_id = ? AND project_id = ?", o, p).by_supplier_no }
  scope :belongs_to_organization_project_supplier, -> o,p,s { includes(:supplier).where("organization_id = ? AND project_id = ? AND supplier_id = ?", o, p, s).by_supplier_no }
  scope :belongs_to_projects, -> p { where("project_id IN (?)", p).by_no }

  # Callbacks
  before_destroy :check_for_dependent_records
  before_save :calculate_and_store_totals
  after_validation :update_user_in_items

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = ""
    if !self.receipt_no.blank?
      full_name += partial_no
    end
    if !self.receipt_date.blank?
      full_name += " " + formatted_date(self.receipt_date)
    end
    if !self.supplier.blank?
      full_name += " " + self.supplier.full_name
    end
    full_name
  end

  def partial_name
    partial_name = ""
    if !self.receipt_no.blank?
      partial_name += self.receipt_no
    end
    if !self.supplier.blank?
      partial_name += " " + self.supplier.full_name
    end
    partial_name
  end

  def partial_no
    receipt_no[0,14]
  end

  def company
    project.company unless project.blank?
  end

  def office
    project.office unless project.blank?
  end

  #
  # Calculated fields
  #
  def subtotal
    receipt_note_items.reject(&:marked_for_destruction?).sum(&:amount)
  end

  def bonus
    (discount_pct / 100) * subtotal if !discount_pct.blank?
  end

  def taxable
    subtotal - bonus - discount
  end

  def taxes
    receipt_note_items.reject(&:marked_for_destruction?).sum(&:net_tax)
  end

  def total
    taxable + taxes
  end

  def quantity
    receipt_note_items.sum(:quantity)
  end

  def balance
    receipt_note_item_balances.sum(:balance)
  end

  # Has meter items?
  def has_meter
    has_meter = false
    receipt_note_items.each do |i|
      if i.is_meter
        has_meter = true
        break
      end
    end
    has_meter
  end

  # Billing status based on current balance
  def billing_status
    if balance <= 0           # fully billed
      _status = I18n.t("activerecord.attributes.receipt_note.billing_status_total")
    elsif balance == quantity # unbilled
      _status = I18n.t("activerecord.attributes.receipt_note.billing_status_unreceived")
    else                      # partially billed
      _status = I18n.t("activerecord.attributes.receipt_note.billing_status_partial")
    end
    _status
  end
  def billing_status_id
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
  def self.unbilled(organization, _ordered)
    if !organization.blank?
      if !_ordered
        includes(:supplier).joins(:receipt_note_item_balances).where('receipt_notes.organization_id = ?', organization).group('receipt_notes.id').having('sum(receipt_note_item_balances.balance) > ?', 0)
      else
        includes(:supplier).joins(:receipt_note_item_balances).where('receipt_notes.organization_id = ?', organization).group('receipt_notes.supplier_id, receipt_notes.receipt_no, receipt_notes.id').having('sum(receipt_note_item_balances.balance) > ?', 0)
      end
    else
      if !_ordered
        includes(:supplier).joins(:receipt_note_item_balances).group('receipt_notes.id').having('sum(receipt_note_item_balances.balance) > ?', 0)
      else
        includes(:supplier).joins(:receipt_note_item_balances).group('receipt_notes.supplier_id, receipt_notes.receipt_no, receipt_notes.id').having('sum(receipt_note_item_balances.balance) > ?', 0)
      end
    end
  end

  def self.unbilled_by_company(s = nil, _ordered)
    if !_ordered
      includes(:supplier, :project).joins(:receipt_note_item_balances).where('projects.company_id = ?', s).group('receipt_notes.id').having('sum(receipt_note_item_balances.balance) > ?', 0)
    else
      includes(:supplier, :project).joins(:receipt_note_item_balances).where('projects.company_id = ?', s).group('receipt_notes.supplier_id, receipt_notes.receipt_no, receipt_notes.id').having('sum(receipt_note_item_balances.balance) > ?', 0)
    end
  end

  def self.unbilled_by_office(s = nil, _ordered)
    if !_ordered
      includes(:supplier, :project).joins(:receipt_note_item_balances).where('projects.office_id = ?', s).group('receipt_notes.id').having('sum(receipt_note_item_balances.balance) > ?', 0)
    else
      includes(:supplier, :project).joins(:receipt_note_item_balances).where('projects.office_id = ?', s).group('receipt_notes.supplier_id, receipt_notes.receipt_no, receipt_notes.id').having('sum(receipt_note_item_balances.balance) > ?', 0)
    end
  end

  def self.unbilled_by_project(_project = nil, _ordered)
    if !_ordered
      includes(:supplier, :project).joins(:receipt_note_item_balances).where('receipt_notes.project_id = ?', _project).group('receipt_notes.id').having('sum(receipt_note_item_balances.balance) > ?', 0)
    else
      includes(:supplier, :project).joins(:receipt_note_item_balances).where('receipt_notes.project_id = ?', _project).group('receipt_notes.supplier_id, receipt_notes.receipt_no, receipt_notes.id').having('sum(receipt_note_item_balances.balance) > ?', 0)
    end
  end

  def self.unbilled_by_project_supplier(_project = nil, _supplier = nil, _ordered = true)
    if !_ordered
      includes(:supplier, :project).joins(:receipt_note_item_balances).where('receipt_notes.project_id = ? AND receipt_notes.supplier_id = ?', _project, _supplier).group('receipt_notes.id').having('sum(receipt_note_item_balances.balance) > ?', 0)
    else
      includes(:supplier, :project).joins(:receipt_note_item_balances).where('receipt_notes.project_id = ? AND receipt_notes.supplier_id = ?', _project, _supplier).group('receipt_notes.supplier_id, receipt_notes.receipt_no, receipt_notes.id').having('sum(receipt_note_item_balances.balance) > ?', 0)
    end
  end

  def self.bill_total #billing_status = 0
    joins(:receipt_note_item_balances).group('receipt_notes.id').having('sum(receipt_note_item_balances.balance) <= ?', 0)
  end

  def self.bill_partial #billing_status = 1
    joins(:receipt_note_item_balances).group('receipt_notes.id').having('sum(receipt_note_item_balances.balance) != sum(receipt_note_items.quantity) AND sum(receipt_note_item_balances.balance) > ? ', 0)
  end

  def self.bill_unbilled #billing_status = 2
    joins(:receipt_note_item_balances).group('receipt_notes.id').having('sum(receipt_note_item_balances.balance) = sum(receipt_note_items.quantity) AND sum(receipt_note_item_balances.balance) > ? ', 0)
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
  def self.to_csv(array)
    attributes = [  array[0].sanitize("Id" + " " + I18n.t("activerecord.models.company.one")),
                    array[0].sanitize(I18n.t("activerecord.models.company.one")),
                    array[0].sanitize(I18n.t("activerecord.attributes.receipt_note.receipt_no")),
                    array[0].sanitize(I18n.t("activerecord.attributes.receipt_note.receipt_date")),
                    array[0].sanitize(I18n.t("activerecord.attributes.receipt_note.project")),
                    array[0].sanitize(I18n.t("activerecord.attributes.receipt_note.project")),
                    array[0].sanitize(I18n.t("activerecord.attributes.receipt_note.store")),
                    array[0].sanitize(I18n.t("activerecord.attributes.purchase_order.charge_account_code")),
                    array[0].sanitize(I18n.t("activerecord.attributes.receipt_note.charge_account")),
                    array[0].sanitize(I18n.t("activerecord.attributes.purchase_order.supplier_code")),
                    array[0].sanitize(I18n.t("activerecord.attributes.receipt_note.supplier")),
                    array[0].sanitize(I18n.t("activerecord.attributes.receipt_note.quantity")),
                    array[0].sanitize(I18n.t("activerecord.attributes.receipt_note.total"))]
    col_sep = I18n.locale == :es ? ";" : ","
    CSV.generate(headers: true, col_sep: col_sep, row_sep: "\r\n") do |csv|
      csv << attributes
      array.each do |i|

        i001 = i.formatted_date(i.receipt_date) unless i.receipt_date.blank?
        i002 = i.raw_number(i.quantity, 2)
        i003 = i.raw_number(i.taxable, 2)
        csv << [  i.try(:project).try(:company).try(:id),
                  i.try(:project).try(:company).try(:name),
                  i.receipt_no,
                  i001,
                  i.try(:project).try(:full_code),
                  i.try(:project).try(:name),
                  i.try(:store).try(:name),
                  i.try(:charge_account).try(:full_code),
                  i.try(:charge_account).try(:partial_name),
                  i.try(:supplier).try(:full_code),
                  i.try(:supplier).try(:name),
                  i002,
                  i003]
      end
    end
  end

  #
  # Records navigator
  #
  def to_first
    ReceiptNote.order("id desc").first
  end

  def to_prev
    ReceiptNote.where("id > ?", id).order("id desc").last
  end

  def to_next
    ReceiptNote.where("id < ?", id).order("id desc").first
  end

  def to_last
    ReceiptNote.order("id desc").last
  end

  searchable do
    text :receipt_no
    string :receipt_no, :multiple => true   # Multiple search values accepted in one search (inverse_no_search)
    integer :id
    integer :payment_method_id
    integer :project_id, :multiple => true
    integer :store_id
    integer :work_order_id
    integer :charge_account_id
    integer :supplier_id
    integer :purchase_order_id
    date :receipt_date
    integer :organization_id
    integer :billing_status_id
  end

  private

  def calculate_and_store_totals
    self.totals = total
  end

  def check_for_dependent_records
    # Check for supplier invoice items
    if supplier_invoice_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.receipt_note.check_for_supplier_invoices'))
      return false
    end
  end

  def update_user_in_items
    true
  end
end
