class PurchaseOrder < ActiveRecord::Base
  belongs_to :offer
  belongs_to :supplier
  belongs_to :payment_method
  belongs_to :order_status
  belongs_to :project
  belongs_to :store
  belongs_to :work_order
  belongs_to :charge_account
  belongs_to :organization
  attr_accessible :discount, :discount_pct, :order_date, :order_no, :remarks, :supplier_offer_no,
                  :supplier_id, :payment_method_id, :order_status_id, :project_id, :offer_id,
                  :store_id, :work_order_id, :charge_account_id, :retention_pct, :retention_time, :organization_id
  attr_accessible :purchase_order_items_attributes
  
  has_many :purchase_order_items, dependent: :destroy
  has_many :receipt_notes
  has_many :receipt_note_items

  # Nested attributes
  accepts_nested_attributes_for :purchase_order_items,                                 
                                :reject_if => :all_blank,
                                :allow_destroy => true
  has_paper_trail

  validates_associated :purchase_order_items
  
  validates :order_date,     :presence => true
  validates :order_no,       :presence => true,
                             :length => { :is => 20 },
                             :format => { with: /\A\d+\Z/, message: :code_invalid },
                             :uniqueness => { :scope => :organization_id }
  validates :supplier,       :presence => true
  validates :payment_method, :presence => true
  validates :order_status,   :presence => true
  validates :project,        :presence => true
  validates :organization,   :presence => true

  before_destroy :check_for_dependent_records

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = full_no
    if !self.order_date.blank?
      full_name += " " + self.order_date.to_s
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
    # Order no (Project code & year & sequential number) => PPPPPPPPPP-YYYY-NNNNNN
    order_no.blank? ? "" : order_no[0..9] + '-' + order_no[10..13] + '-' + order_no[14..19]
  end

  #
  # Calculated fields
  #
  def subtotal
    subtotal = 0
    purchase_order_items.each do |i|
      if !i.amount.blank?
        subtotal += i.amount
      end
    end
    subtotal
  end

  def bonus
    (discount_pct / 100) * subtotal if !discount_pct.blank?
  end
  
  def taxable
    subtotal - bonus - discount
  end

  def taxes
    taxes = 0
    purchase_order_items.each do |i|
      if !i.net_tax.blank?
        taxes += i.net_tax
      end
    end
    taxes
  end

  def total
    taxable + taxes  
  end
  
  def balance
    balance = 0
    purchase_order_items.each do |i|
      if !i.balance.blank?
        balance += i.balance
      end
    end
    balance
  end

  def quantity
    purchase_order_items.sum("quantity")
  end
  
  def delivery_avg
    avg, cnt = 0, 0
    purchase_order_items.each do |i|
      if !i.delivery_date.blank?
        avg = Time.parse(i.delivery_date.to_s).to_f
        cnt += 1
      end
    end
    cnt > 0 ? Date.parse(Time.at(avg / cnt).to_s) : nil
  end

  def offer_no
    offer.nil? ? nil : offer.offer_no  
  end
  
  #
  # Records navigator
  #
  def to_first
    PurchaseOrder.order("order_no").first
  end

  def to_prev
    PurchaseOrder.where("id < ?", id).order("order_no").last
  end

  def to_next
    PurchaseOrder.where("id > ?", id).order("order_no").first
  end

  def to_last
    PurchaseOrder.order("order_no").last
  end

  searchable do
    text :order_no, :supplier_offer_no
    string :order_no
    integer :supplier_id
    integer :payment_method_id
    integer :order_status_id
    integer :project_id, :multiple => true
    integer :store_id
    integer :work_order_id
    integer :charge_account_id
    integer :offer_id
    date :order_date
    integer :organization_id
  end

  private

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
end
