class PurchaseOrder < ActiveRecord::Base
  include ModelsModule
  
  belongs_to :offer
  belongs_to :supplier
  belongs_to :payment_method
  belongs_to :order_status
  belongs_to :project
  belongs_to :store
  belongs_to :work_order
  belongs_to :charge_account
  belongs_to :organization
  belongs_to :approver, class_name: 'User'
  attr_accessible :discount, :discount_pct, :order_date, :order_no, :remarks, :supplier_offer_no,
                  :supplier_id, :payment_method_id, :order_status_id, :project_id, :offer_id,
                  :store_id, :work_order_id, :charge_account_id, :retention_pct, :retention_time,
                  :organization_id, :approver_id, :approval_date
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

  before_destroy :check_for_dependent_records
  after_save :notify_on_save

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
    tt = global_tax_breakdown(purchase_order_items, true)
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
  # After save
  def notify_on_save
    Notifier.purchase_order_saved(self).deliver
    if check_if_approval_is_required
      Notifier.purchase_order_saved_with_approval(self).deliver
    end     
  end

  #
  # Helper methods for notifiers
  #
  # Need approval?
  def check_if_approval_is_required
    check_by_families
  end

  # Maximums by product family
  # Returns true if approval is required, otherwise false
  def check_by_families
    _r = false
    # global_family_breakdown returns multidimensional array containing different product family in each line
    # Each line contains 5 elements: Family Id, max_orders_count, max_orders_sum, Quantity sum & Net amount sum
    pfs = global_family_breakdown(purchase_order_items.joins(:product).order(:product_family_id))
    pf = pfs.detect { |f| (f[3] > f[1]) || (f[4] > f[2]) }
    _r = pf.nil? ? false : true
  end 
end
