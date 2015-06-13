class WorkOrder < ActiveRecord::Base
  include ModelsModule

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
  attr_accessible :closed_at, :completed_at, :order_no, :started_at,
                  :work_order_labor_id, :work_order_status_id, :work_order_type_id,
                  :charge_account_id, :project_id, :area_id, :store_id, :client_id,
                  :remarks, :description, :petitioner, :master_order_id, :organization_id,
                  :in_charge_id, :reported_at, :approved_at, :certified_at, :posted_at,
                  :location, :pub_record
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
  has_many :offers_items
  has_many :supplier_invoices
  has_many :supplier_invoice_items
  has_many :delivery_notes
  has_many :delivery_note_items
  has_many :sale_offers  
  has_many :sale_offer_items

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
  validates :charge_account,    :presence => true
  validates :project,           :presence => true
  validates :work_order_labor,  :presence => true
  validates :work_order_status, :presence => true
  validates :work_order_type,   :presence => true
  validates :in_charge,         :presence => true
  validates :organization,      :presence => true

  before_destroy :check_for_dependent_records

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
    # Order no (Project code & year & sequential number) => PPPPPPPPPPPP-YYYY-NNNNNN
    order_no.blank? ? "" : order_no[0..11] + '-' + order_no[12..15] + '-' + order_no[16..21]
  end

  #
  # Calculated fields
  #
  def item_costs
    costs = 0
    work_order_items.each do |i|
      if !i.costs.blank?
        costs += i.costs
      end
    end
    costs
  end

  def subtotal
    subtotal = 0
    work_order_items.each do |i|
      if !i.amount.blank?
        subtotal += i.amount
      end
    end
    subtotal
  end
  
  def taxable
    subtotal
  end

  def taxes
    taxes = 0
    work_order_items.each do |i|
      if !i.tax.blank?
        taxes += i.tax
      end
    end
    taxes
  end

  def total
    taxable + taxes  
  end

  def quantity
    work_order_items.sum("quantity")
  end

  def worker_costs
    costs = 0
    work_order_workers.each do |i|
      if !i.costs.blank?
        costs += i.costs
      end
    end
    costs
  end

  def hours
    work_order_workers.sum("hours")
  end
  
  def hours_avg
    hours / work_order_workers.count
  end
  
  def total_costs
    item_costs + worker_costs + tool_costs + vehicle_costs + subcontractor_costs
  end

  def tool_costs
    costs = 0
    work_order_tools.each do |i|
      if !i.costs.blank?
        costs += i.costs
      end
    end
    costs
  end

  def tool_minutes
    work_order_tools.sum("minutes")
  end

  def vehicle_costs
    costs = 0
    work_order_vehicles.each do |i|
      if !i.costs.blank?
        costs += i.costs
      end
    end
    costs
  end

  def vehicle_distance
    work_order_vehicles.sum("distance")
  end

  def subcontractor_costs
    costs = 0
    work_order_subcontractors.each do |i|
      if !i.costs.blank?
        costs += i.costs
      end
    end
    costs
  end

  # Returns multidimensional array containing different tax type in each line
  # Each line contains 5 elements: Id, Description, Tax %, Amount & Tax
  def tax_breakdown
    tt = global_tax_breakdown(work_order_items, false)
  end
  
  #
  # Records navigator
  #
  def to_first
    WorkOrder.order("order_no").first
  end

  def to_prev
    WorkOrder.where("order_no < ?", id).order("order_no").last
  end

  def to_next
    WorkOrder.where("order_no > ?", id).order("order_no").first
  end

  def to_last
    WorkOrder.order("order_no").last
  end

  searchable do
    text :order_no, :description, :petitioner
    string :order_no, :multiple => true   # Multiple search values accepted in one search (inverse_no_search)
    integer :charge_account_id
    integer :project_id, :multiple => true
    integer :client_id
    integer :work_order_type_id
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
  end
end
