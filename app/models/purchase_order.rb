class PurchaseOrder < ActiveRecord::Base
  belongs_to :offer
  belongs_to :supplier
  belongs_to :payment_method
  belongs_to :order_status
  belongs_to :project
  belongs_to :store
  belongs_to :work_order
  belongs_to :charge_account
  attr_accessible :discount, :discount_pct, :order_date, :order_no, :remarks, :supplier_offer_no,
                  :supplier_id, :payment_method_id, :order_status_id, :project_id, :offer_id,
                  :store_id, :work_order_id, :charge_account_id, :retention_pct, :retention_time
  attr_accessible :purchase_order_items_attributes
  
  has_many :purchase_order_items, dependent: :destroy
  has_many :receipt_note_items

  accepts_nested_attributes_for :purchase_order_items,                                 
                                :reject_if => lambda { |attrs| attrs.all? { |key, value| value.blank? } },
                                :allow_destroy => true
  has_paper_trail

  validates :order_date,     :presence => true
  validates :order_no,       :presence => true,
                             :length => { :minimum => 5 },
                             :uniqueness => true
  validates :supplier,       :presence => true
  validates :payment_method, :presence => true
  validates :order_status,   :presence => true

  before_destroy :check_for_dependent_records

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

  private

  def check_for_dependent_records
    # Check for receipt note items
    if receipt_note_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.purchase_order.check_for_receipt_notes'))
      return false
    end
  end
end
