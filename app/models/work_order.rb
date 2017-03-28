class WorkOrder < ActiveRecord::Base
  include ModelsModule

  belongs_to :work_order_area
  belongs_to :work_order_type
  belongs_to :work_order_status
  belongs_to :work_order_labor
  belongs_to :charge_account
  belongs_to :project
  belongs_to :area
  belongs_to :store
  belongs_to :client
  belongs_to :organization
  belongs_to :in_charge, class_name: 'Worker'
  belongs_to :infrastructure
  belongs_to :subscriber
  belongs_to :meter
  belongs_to :meter_model
  belongs_to :meter_owner
  belongs_to :meter_location
  belongs_to :caliber
  belongs_to :last_reading, class_name: 'Reading'
  attr_accessible :closed_at, :completed_at, :order_no, :started_at,
                  :work_order_labor_id, :work_order_status_id, :work_order_type_id, :work_order_area_id,
                  :charge_account_id, :project_id, :area_id, :store_id, :client_id, :infrastructure_id,
                  :remarks, :description, :petitioner, :master_order_id, :organization_id,
                  :in_charge_id, :reported_at, :approved_at, :certified_at, :posted_at,
                  :location, :pub_record, :subscriber_id, :incidences, :por_affected,
                  :meter_id, :meter_code, :meter_model_id, :caliber_id, :meter_owner_id,
                  :meter_location_id, :last_reading_id, :current_reading_date, :current_reading_index, :hours_type,
                  :totals, :this_costs, :with_suborder_costs
  attr_accessible :work_order_items_attributes, :work_order_workers_attributes,
                  :work_order_tools_attributes, :work_order_vehicles_attributes,
                  :work_order_subcontractors_attributes

  has_many :work_order_items, dependent: :destroy
  has_many :work_order_workers, dependent: :destroy
  has_many :work_order_tools, dependent: :destroy
  has_many :work_order_vehicles, dependent: :destroy
  has_many :work_order_subcontractors, dependent: :destroy
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

  #HOURS_TYPES = [[0, I18n.t("hours_type.regular")], [1, I18n.t("hours_type.overtime")], [2, I18n.t("hours_type.urgency")], [3, I18n.t("hours_type.oncall")]]
  HOURS_TYPES = {0 => I18n.t("hours_type.regular"), 1 => I18n.t("hours_type.overtime"), 2 => I18n.t("hours_type.urgency"), 3 => I18n.t("hours_type.oncall")}

  # Nested attributes
  accepts_nested_attributes_for :work_order_items,
                                :reject_if => :all_blank,
                                :allow_destroy => true
  accepts_nested_attributes_for :work_order_workers,
                                :reject_if => :all_blank,
                                :allow_destroy => true
  accepts_nested_attributes_for :work_order_tools,
                                :reject_if => :all_blank,
                                :allow_destroy => true
  accepts_nested_attributes_for :work_order_vehicles,
                                :reject_if => :all_blank,
                                :allow_destroy => true
  accepts_nested_attributes_for :work_order_subcontractors,
                                :reject_if => :all_blank,
                                :allow_destroy => true

  # Self join
  has_many :suborders, class_name: 'WorkOrder', foreign_key: 'master_order_id'
  belongs_to :master_order, class_name: 'WorkOrder'

  has_paper_trail

  validates_associated :work_order_items, :work_order_workers,
                       :work_order_tools, :work_order_vehicles,
                       :work_order_subcontractors

  validates :order_no,          :presence => true,
                                :length => { :is => 22 },
                                :format => { with: /\A[a-zA-Z\d]+\Z/, message: :code_invalid },
                                :uniqueness => { :scope => :organization_id }
  validates :description,       :presence => true,
                                :length => { :maximum => 100 }
  #validates :charge_account,    :presence => true
  validates :project,           :presence => true
  validates :work_order_labor,  :presence => true
  validates :work_order_status, :presence => true
  validates :work_order_area,   :presence => true
  validates :work_order_type,   :presence => true
  validates :in_charge,         :presence => true
  validates :organization,      :presence => true
  validates :started_at,        :presence => true, :if => "!completed_at.blank?"
  validates :completed_at,      :presence => true, :if => "!closed_at.blank?"

  validate :completed_at_cannot_be_less_than_started_at
  validate :closed_at_cannot_be_less_than_completed_at

  #
  # Scopes
  #
  scope :by_no, -> { order(:order_no) }
  # by Project
  scope :belongs_to_project, -> project { where("project_id = ?", project).by_no }
  scope :belongs_to_project_unclosed, -> project { where("project_id = ? AND closed_at IS NULL", project).by_no }
  scope :belongs_to_project_unclosed_without_this, -> project, this { where("project_id = ? AND closed_at IS NULL AND id <> ?", project, this).by_no }
  scope :belongs_to_project_unclosed_without_suborders, -> project { where("project_id = ? AND closed_at IS NULL AND master_order_id IS NULL", project).by_no }
  scope :belongs_to_project_unclosed_without_this_and_suborders, -> project, this { where("project_id = ? AND closed_at IS NULL AND id <> ? AND master_order_id IS NULL", project, this).by_no }
  scope :belongs_to_project_unclosed_and_this, -> project, this { where("(project_id = ? AND closed_at IS NULL) OR id = ?", project, this).by_no }
  # by Organization
  scope :belongs_to_organization, -> org { where("organization_id = ?", org).by_no }
  scope :belongs_to_organization_unclosed, -> org { where("organization_id = ? AND closed_at IS NULL", org).by_no }
  scope :belongs_to_organization_unclosed_without_this, -> org, this { where("organization_id = ? AND closed_at IS NULL AND id <> ?", org, this).by_no }
  scope :belongs_to_organization_unclosed_without_suborders, -> org { where("organization_id = ? AND closed_at IS NULL AND master_order_id IS NULL", org).by_no }
  scope :belongs_to_organization_unclosed_without_this_and_suborders, -> org, this { where("organization_id = ? AND closed_at IS NULL AND id <> ? AND master_order_id IS NULL", org, this).by_no }
  scope :belongs_to_organization_unclosed_and_this, -> org, this { where("(organization_id = ? AND closed_at IS NULL) OR id = ?", org, this).by_no }
  # generic where (eg. for Select2 from engines_controller)
  scope :g_where, -> w {
    joins(:project)
    .where(w)
    .by_no
  }

  # Callbacks
  before_destroy :check_for_dependent_records
  before_save :calculate_and_store_totals
  before_save :update_status_based_on_dates
  before_save :update_dates_based_on_status

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = full_no
    full_name += " " + summary
    full_name
  end

  def summary
    description.blank? ? "N/A" : description[0,40]
  end

  def full_no
    # Order no (Project code & year & sequential number) => PPPPPPPPPPPP-YYYY-NNNNNN M
    order_no.blank? ? "" : order_no[0..11] + '-' + order_no[12..15] + '-' + order_no[16..21] + complete_full_no_if_suborders
  end

  def completed_at_cannot_be_less_than_started_at
    if (!completed_at.blank? and !started_at.blank?) and completed_at < started_at
      errors.add(:completed_at, :date_invalid)
    end
  end

  def closed_at_cannot_be_less_than_completed_at
    if (!closed_at.blank? and !completed_at.blank?) and closed_at < completed_at
      errors.add(:closed_at, :date_invalid)
    end
  end

  def area_type_labor
    atl = ""
    if !work_order_area.blank?
      atl += work_order_area.short_name
    end
    if !work_order_type.blank?
      atl += atl.blank? ? work_order_type.short_name : " - " + work_order_type.short_name
    end
    if !work_order_labor.blank?
      atl += atl.blank? ? work_order_labor.short_name : " - " + work_order_labor.short_name
    end
    atl
  end

  def area_type
    atl = ""
    if !work_order_area.blank?
      atl += work_order_area.short_name
    end
    if !work_order_type.blank?
      atl += atl.blank? ? work_order_type.short_name : "-" + work_order_type.short_name
    end
    atl
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
  def item_costs
    work_order_items.reject(&:marked_for_destruction?).sum(&:costs)
  end

  def subtotal
    work_order_items.reject(&:marked_for_destruction?).sum(&:amount)
  end

  def taxable
    subtotal
  end

  def taxes
    work_order_items.reject(&:marked_for_destruction?).sum(&:tax)
  end

  def total
    taxable + taxes
  end

  def quantity
    work_order_items.sum(:quantity)
  end

  def worker_costs
    work_order_workers.reject(&:marked_for_destruction?).sum(&:costs)
  end

  def hours
    work_order_workers.sum(:hours)
  end

  def hours_avg
    hours / work_order_workers.count
  end

  # Total costs, this WO only
  def this_total_costs
    item_costs + worker_costs + tool_costs + vehicle_costs + subcontractor_costs
  end

  # Total costs, including suborder costs
  def total_costs
    item_costs + worker_costs + tool_costs + vehicle_costs + subcontractor_costs + suborder_costs
  end

  def tool_costs
    work_order_tools.reject(&:marked_for_destruction?).sum(&:costs)
  end

  def tool_minutes
    work_order_tools.sum(:minutes)
  end

  def vehicle_costs
    work_order_vehicles.reject(&:marked_for_destruction?).sum(&:costs)
  end

  def vehicle_distance
    work_order_vehicles.sum(:distance)
  end

  def subcontractor_costs
    work_order_subcontractors.reject(&:marked_for_destruction?).sum(&:costs)
  end

  def suborder_costs
    suborders.reject(&:marked_for_destruction?).sum(&:total_costs)
  end

  # Returns multidimensional array containing different tax type in each line
  # Each line contains 5 elements: Id, Description, Tax %, Amount & Tax
  def tax_breakdown
    global_tax_breakdown(work_order_items, false)
  end

  # Are there unclosed linked suborders?
  def are_there_unclosed_suborders?
    suborders.unclosed_only.count > 0 ? true : false
  end

  # Have suborders?
  def have_suborders?
    suborders.size > 0 ? true : false
  end

  # Are there unclosed linked suborders?
  def complete_full_no_if_suborders
    have_suborders? ? I18n.t('activerecord.attributes.work_order.master_c') : ""
  end

  #
  # Class (self) user defined methods
  #
  # Unstarted
  def self.unstarted(project = nil)
    if project.blank?
      where('started_at IS NULL').order(:order_no)
    else
      where('project_id = ? AND started_at IS NULL', project).order(:order_no)
    end
  end

  # Started but uncompleted
  def self.uncompleted(project = nil)
    if project.blank?
      where('NOT started_at IS NULL AND completed_at IS NULL').order(:order_no)
    else
      where('project_id = ? AND (NOT started_at IS NULL AND completed_at IS NULL)', project).order(:order_no)
    end
  end

  # Completed but unclosed
  def self.unclosed(project = nil)
    if project.blank?
      where('NOT completed_at IS NULL AND closed_at IS NULL').order(:order_no)
    else
      where('project_id = ? AND (NOT completed_at IS NULL AND closed_at IS NULL)', project).order(:order_no)
    end
  end

  # Unclosed
  def self.unclosed_only(project = nil)
    if project.blank?
      where('closed_at IS NULL').by_no
    else
      where('project_id = ? AND closed_at IS NULL', project).by_no
    end
  end

  # Unclosed without suborders
  def self.unclosed_only_without_suborders(project = nil)
    if project.blank?
      where('closed_at IS NULL AND master_order_id IS NULL').by_no
    else
      where('project_id = ? AND closed_at IS NULL AND master_order_id IS NULL', project).by_no
    end
  end

  # Unclosed without current
  def self.unclosed_only_without_this(project = nil, this = nil)
    if project.blank?
      if this.blank?
        where('closed_at IS NULL').by_no
      else
        where('closed_at IS NULL AND id <> ?', this).by_no
      end
    else
      if this.blank?
        where('project_id = ? AND closed_at IS NULL', project).by_no
      else
        where('project_id = ? AND closed_at IS NULL AND id <> ?', project, this).by_no
      end
    end
  end

  # Unclosed without current & suborders
  def self.unclosed_only_without_this_and_suborders(project = nil, this = nil)
    if project.blank?
      if this.blank?
        where('closed_at IS NULL AND master_order_id IS NULL').by_no
      else
        where('closed_at IS NULL AND master_order_id IS NULL AND id <> ?', this).by_no
      end
    else
      if this.blank?
        where('project_id = ? AND closed_at IS NULL AND master_order_id IS NULL', project).by_no
      else
        where('project_id = ? AND closed_at IS NULL AND master_order_id IS NULL AND id <> ?', project, this).by_no
      end
    end
  end

  # Closed
  def self.closed(project = nil)
    if project.blank?
      where('NOT closed_at IS NULL').order(:order_no)
    else
      where('project_id = ? AND (NOT closed_at IS NULL)', project).order(:order_no)
    end
  end

  #
  # Records navigator
  #
  def to_first
    WorkOrder.order("order_no desc").first
  end

  def to_prev
    WorkOrder.where("order_no > ?", order_no).order("order_no desc").last
  end

  def to_next
    WorkOrder.where("order_no < ?", order_no).order("order_no desc").first
  end

  def to_last
    WorkOrder.order("order_no desc").last
  end

  searchable do
    text :order_no, :description, :petitioner, :location
    string :order_no, :multiple => true   # Multiple search values accepted in one search (inverse_no_search)
    integer :charge_account_id
    integer :project_id, :multiple => true
    integer :client_id
    integer :work_order_area_id
    integer :work_order_type_id
    integer :work_order_labor_id
    integer :work_order_status_id
    integer :client_id
    integer :master_order_id
    date :started_at
    date :completed_at
    date :closed_at
    integer :organization_id
    string :sort_no do
      order_no
    end
  end

  private

  def calculate_and_store_totals
    self.totals = total
    self.this_costs = this_total_costs
    self.with_suborder_costs = total_costs
  end

  def check_for_dependent_records
    # Check for purchase orders
    if purchase_orders.count > 0
      errors.add(:base, I18n.t('activerecord.models.work_order.check_for_purchase_orders'))
      return false
    end
    # Check for purchase order items
    if purchase_order_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.work_order.check_for_purchase_orders'))
      return false
    end
    # Check for receipt notes
    if receipt_notes.count > 0
      errors.add(:base, I18n.t('activerecord.models.work_order.check_for_receipt_notes'))
      return false
    end
    # Check for receipt note items
    if receipt_note_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.work_order.check_for_receipt_notes'))
      return false
    end
    # Check for delivery notes
    if delivery_notes.count > 0
      errors.add(:base, I18n.t('activerecord.models.work_order.check_for_delivery_notes'))
      return false
    end
    # Check for delivery note items
    if delivery_note_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.work_order.check_for_delivery_notes'))
      return false
    end
    # Check for offer requests
    if offer_requests.count > 0
      errors.add(:base, I18n.t('activerecord.models.work_order.check_for_offer_requests'))
      return false
    end
    # Check for offer request items
    if offer_request_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.work_order.check_for_offer_requests'))
      return false
    end
    # Check for offers
    if offers.count > 0
      errors.add(:base, I18n.t('activerecord.models.work_order.check_for_offers'))
      return false
    end
    # Check for offer items
    if offer_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.work_order.check_for_offers'))
      return false
    end
    # Check for supplier invoices
    if supplier_invoices.count > 0
      errors.add(:base, I18n.t('activerecord.models.work_order.check_for_supplier_invoices'))
      return false
    end
    # Check for supplier invoice items
    if supplier_invoice_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.work_order.check_for_supplier_invoices'))
      return false
    end
    # Check for sale offers
    if sale_offers.count > 0
      errors.add(:base, I18n.t('activerecord.models.work_order.check_for_sale_offers'))
      return false
    end
    # Check for sale offer items
    if sale_offer_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.work_order.check_for_sale_offers'))
      return false
    end
    # Check for suborders
    if suborders.count > 0
      errors.add(:base, I18n.t('activerecord.models.work_order.check_for_suborders'))
      return false
    end
  end

  #
  # Before save (create & update)
  #
  # Status and related dates
  # 1->unstarted
  # 2->started & uncompleted
  # 3->completed & unclosed
  # 4->closed
  #
  # Update status
  def update_status_based_on_dates
    if started_at_was.blank? && !started_at.blank? && work_order_status_id < 2
      self.work_order_status_id = 2
    end
    if completed_at_was.blank? && !completed_at.blank? && work_order_status_id < 3
      self.work_order_status_id = 3
    end
    if closed_at_was.blank? && !closed_at.blank? && work_order_status_id < 4
      # Cannot close order if there is unclosed suborders
      if are_there_unclosed_suborders?
        self.closed_at = closed_at_was
        errors.add(:base, I18n.t('activerecord.models.work_order.check_for_unclosed_suborders'))
        return false
      end
      self.work_order_status_id = 4
    end
    true
  end

  # Update dates
  def update_dates_based_on_status
    if work_order_status_id != work_order_status_id_was
      if work_order_status_id == 2 && started_at.blank?
        self.started_at = Time.now
      end
      if work_order_status_id == 3 && completed_at.blank?
        self.completed_at = Time.now
      end
      if work_order_status_id == 4 && closed_at.blank?
        # Cannot close order if there are unclosed suborders
        if are_there_unclosed_suborders?
          errors.add(:base, I18n.t('activerecord.models.work_order.check_for_unclosed_suborders'))
          return false
        end
        self.closed_at = Time.now
      end
    end
    true
  end
end
