class DeliveryNote < ActiveRecord::Base
  belongs_to :client
  belongs_to :payment_method
  belongs_to :project
  belongs_to :store
  belongs_to :work_order
  belongs_to :charge_account
  attr_accessible :delivery_date, :delivery_no, :discount, :discount_pct, :remarks,
                  :client_id, :payment_method_id, :project_id, :store_id, :work_order_id,
                  :charge_account_id

  has_many :delivery_note_items, dependent: :destroy
  has_many :client_invoice_items

  has_paper_trail

  validates :delivery_date,   :presence => true
  validates :delivery_no,     :presence => true

  before_destroy :check_for_dependent_records

  #
  # Records navigator
  #
  def to_first
    DeliveryNote.order("id").first
  end

  def to_prev
    DeliveryNote.where("id < ?", id).order("id").last
  end

  def to_next
    DeliveryNote.where("id > ?", id).order("id").first
  end

  def to_last
    DeliveryNote.order("id").last
  end

  private

  def check_for_dependent_records
    # Check for client invoice items
    if client_invoice_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.delivery_note.check_for_client_invoices'))
      return false
    end
  end
end
