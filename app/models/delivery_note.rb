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

  # Nested attributes
  accepts_nested_attributes_for :delivery_note_items,                                 
                                :reject_if => :all_blank,
                                :allow_destroy => true

  has_paper_trail

  validates_associated :delivery_note_items

  validates :delivery_date,   :presence => true
  validates :delivery_no,     :presence => true

  before_destroy :check_for_dependent_records

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = ""
    if !self.delivery_no.blank?
      full_name += self.delivery_no
    end
    if !self.delivery_date.blank?
      full_name += " " + self.delivery_date
    end
    if !self.work_order.blank?
      full_name += " " + self.work_order.full_name
    else
      if !self.client.blank?
        full_name += " " + self.client.full_name
      end
    end
    full_name
  end

  #
  # Calculated fields
  #
  def costs
    costs = 0
    delivery_note_items.each do |i|
      if !i.costs.blank?
        costs += i.costs
      end
    end
    costs
  end

  def subtotal
    subtotal = 0
    delivery_note_items.each do |i|
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
    delivery_note_items.each do |i|
      if !i.net_tax.blank?
        taxes += i.net_tax
      end
    end
    taxes
  end

  def total
    taxable + taxes  
  end

  def quantity
    delivery_note_items.sum("quantity")
  end

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
