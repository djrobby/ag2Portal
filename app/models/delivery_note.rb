class DeliveryNote < ActiveRecord::Base
  belongs_to :client
  belongs_to :payment_method
  belongs_to :project
  belongs_to :store
  belongs_to :work_order
  belongs_to :charge_account
  belongs_to :sale_offer
  belongs_to :organization
  attr_accessible :delivery_date, :delivery_no, :discount, :discount_pct, :remarks,
                  :client_id, :payment_method_id, :project_id, :store_id, :work_order_id,
                  :charge_account_id, :sale_offer_id, :organization_id
  attr_accessible :delivery_note_items_attributes

  has_many :delivery_note_items, dependent: :destroy
  has_many :client_invoice_items

  # Nested attributes
  accepts_nested_attributes_for :delivery_note_items,                                 
                                :reject_if => :all_blank,
                                :allow_destroy => true

  has_paper_trail

  validates_associated :delivery_note_items

  validates :delivery_date,   :presence => true
  validates :delivery_no,     :presence => true,
                              :length => { :is => 14 },
                              :format => { with: /\A\d+\Z/, message: :code_invalid },
                              :uniqueness => { :scope => :organization_id }
  validates :project,         :presence => true
  validates :organization,    :presence => true

  before_destroy :check_for_dependent_records

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = full_no
    if !self.delivery_date.blank?
      full_name += " " + self.delivery_date.to_s
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

  def partial_name
    partial_name = full_no
    if !self.delivery_date.blank?
      full_name += " " + self.delivery_date.to_s
    end
    partial_name
  end

  def full_no
    # Delivery no (Organization id & year & sequential number) => OOOO-YYYY-NNNNNN
    delivery_no.blank? ? "" : delivery_no[0..3] + '-' + delivery_no[4..7] + '-' + delivery_no[8..13]
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
    DeliveryNote.order("delivery_no").first
  end

  def to_prev
    DeliveryNote.where("delivery_no < ?", delivery_no).order("delivery_no").last
  end

  def to_next
    DeliveryNote.where("delivery_no > ?", delivery_no).order("delivery_no").first
  end

  def to_last
    DeliveryNote.order("delivery_no").last
  end

  searchable do
    text :delivery_no
    string :delivery_no, :multiple => true    # Multiple search values accepted in one search (inverse_no_search)
    integer :payment_method_id
    integer :project_id, :multiple => true
    integer :store_id
    integer :work_order_id
    integer :charge_account_id
    integer :client_id
    date :delivery_date
    integer :organization_id
    string :sort_no do
      delivery_no
    end
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
