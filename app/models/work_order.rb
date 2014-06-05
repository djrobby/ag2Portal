class WorkOrder < ActiveRecord::Base
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

  has_many :work_order_items, dependent: :destroy
  has_many :work_order_workers, dependent: :destroy
  has_many :purchase_orders
  has_many :receipt_notes
  has_many :receipt_note_items
  has_many :supplier_invoices

  # Self join
  has_many :suborders, class_name: 'WorkOrder', foreign_key: 'master_order_id'
  belongs_to :master_order, class_name: 'WorkOrder'
  
  has_paper_trail

  validates :order_no,          :presence => true,
                                :length => { :in => 7..17 },
                                :uniqueness => true
  validates :description,       :presence => true,
                                :length => { :maximum => 100 }
  validates :charge_account,    :presence => true
  validates :project,           :presence => true
  validates :work_order_labor,  :presence => true
  validates :work_order_status, :presence => true
  validates :work_order_type,   :presence => true
  validates :in_charge,         :presence => true

  before_destroy :check_for_dependent_records

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = ""
    if !self.order_no.blank?
      full_name += self.order_no
    end
    full_name += " " + summary
    full_name
  end

  def summary
    description.blank? ? "N/A" : description[0,40]
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
    string :order_no
    integer :charge_account_id
    integer :project_id
    integer :client_id
    integer :work_order_type_id
    integer :work_order_status_id
    integer :client_id
    integer :master_order_id
    date :started_at
    date :completed_at
    date :closed_at
  end

  private

  def check_for_dependent_records
    # Check for purchase orders
    if purchase_orders.count > 0
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
    # Check for supplier invoices
    if supplier_invoices.count > 0
      errors.add(:base, I18n.t('activerecord.models.work_order.check_for_supplier_invoices'))
      return false
    end
  end
end
