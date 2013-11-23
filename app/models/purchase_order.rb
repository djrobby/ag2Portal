class PurchaseOrder < ActiveRecord::Base
  belongs_to :supplier
  belongs_to :payment_method
  belongs_to :order_status
  attr_accessible :discount, :discount_pct, :order_date, :order_no, :remarks, :supplier_offer_no,
                  :supplier_id, :payment_method_id, :order_status_id

  has_paper_trail

  validates :order_date,        :presence => true
  validates :order_no,          :presence => true,
                                :length => { :minimum => 5 },
                                :uniqueness => true
  validates :supplier_id,       :presence => true
  validates :payment_method_id, :presence => true
  validates :order_status_id,   :presence => true

  has_many :purchase_order_items, dependent: :destroy

  #
  # Records navigator
  #
  def to_first
    PurchaseOrder.order("id").first
  end

  def to_prev
    PurchaseOrder.where("id < ?", id).order("id").last
  end

  def to_next
    PurchaseOrder.where("id > ?", id).order("id").first
  end

  def to_last
    PurchaseOrder.order("id").last
  end
end
