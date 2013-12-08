class ReceiptNote < ActiveRecord::Base
  belongs_to :purchase_order
  belongs_to :supplier
  belongs_to :payment_method
  belongs_to :project
  belongs_to :store
  belongs_to :work_order
  belongs_to :charge_account
  attr_accessible :discount, :discount_pct, :receipt_date, :receipt_no, :remarks, :retention_pct, :retention_time,
                  :purchase_order_id, :supplier_id, :payment_method_id, :project_id,
                  :store_id, :work_order_id, :charge_account_id

  has_many :receipt_note_items, dependent: :destroy

  has_paper_trail

  validates :receipt_date,   :presence => true
  validates :receipt_no,     :presence => true
  validates :supplier,       :presence => true
  validates :payment_method, :presence => true
  validates :project,        :presence => true

  #
  # Records navigator
  #
  def to_first
    ReceiptNote.order("id").first
  end

  def to_prev
    ReceiptNote.where("id < ?", id).order("id").last
  end

  def to_next
    ReceiptNote.where("id > ?", id).order("id").first
  end

  def to_last
    ReceiptNote.order("id").last
  end
end
