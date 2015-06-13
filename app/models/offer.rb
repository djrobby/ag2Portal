class Offer < ActiveRecord::Base
  include ModelsModule

  belongs_to :offer_request
  belongs_to :supplier
  belongs_to :payment_method
  belongs_to :project
  belongs_to :store
  belongs_to :work_order
  belongs_to :charge_account
  belongs_to :organization
  belongs_to :approver, class_name: 'User'
  attr_accessible :offer_date, :offer_no, :remarks, :discount_pct, :discount,
                  :offer_request_id, :supplier_id, :payment_method_id,
                  :project_id, :store_id, :work_order_id, :charge_account_id,
                  :organization_id, :approver_id, :approval_date, :attachment
  attr_accessible :offer_items_attributes
  has_attached_file :attachment, :styles => { :medium => "192x192>", :small => "128x128>" }, :default_url => "/images/missing/:style/attachment.png"
  
  has_many :offer_items, dependent: :destroy
  has_many :purchase_orders
  #has_one :approver_offer_request, class_name: 'OfferRequest', foreign_key: 'approved_offer_id'

  # Nested attributes
  accepts_nested_attributes_for :offer_items,                                 
                                :reject_if => :all_blank,
                                :allow_destroy => true

  has_paper_trail

  validates_associated :offer_items

  validates :offer_date,      :presence => true
  validates :offer_no,        :presence => true,
                              :uniqueness => { :scope => [ :organization_id, :supplier_id ] }
  validates :supplier,        :presence => true
  validates :payment_method,  :presence => true
  validates :offer_request,   :presence => true
  validates :project,         :presence => true
  validates :organization,    :presence => true

  validates_attachment_content_type :attachment, :content_type => /\Aimage\/.*\Z/, :message => :attachment_invalid

  before_destroy :check_for_dependent_records
  after_create :notify_on_create
  after_update :notify_on_update

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = ""
    if !self.offer_no.blank?
      full_name += self.offer_no
    end
    if !self.offer_date.blank?
      full_name += " " + formatted_date(self.offer_date)
    end
    if !self.supplier.blank?
      full_name += " " + self.supplier.full_name
    end
    full_name
  end

  def partial_name
    partial_name = ""
    if !self.offer_no.blank?
      partial_name += self.offer_no
    end
    if !self.supplier.blank?
      partial_name += " " + self.supplier.name[0,40]
    end
    partial_name
  end

  #
  # Calculated fields
  #
  def subtotal
    subtotal = 0
    offer_items.each do |i|
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
    offer_items.each do |i|
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
    offer_items.sum("quantity")
  end

  #
  # Records navigator
  #
  def to_first
    Offer.order("id").first
  end

  def to_prev
    Offer.where("id < ?", id).order("id").last
  end

  def to_next
    Offer.where("id > ?", id).order("id").first
  end

  def to_last
    Offer.order("id").last
  end

  searchable do
    text :offer_no
    string :offer_no, :multiple => true   # Multiple search values accepted in one search (inverse_no_search)
    integer :id
    integer :supplier_id
    integer :payment_method_id
    integer :project_id
    integer :store_id
    integer :work_order_id
    integer :charge_account_id
    date :offer_date
    integer :organization_id
  end

  private

  def check_for_dependent_records
    # Check for purchase orders
    if purchase_orders.count > 0
      errors.add(:base, I18n.t('activerecord.models.offer.check_for_purchase_orders'))
      return false
    end
  end

  #
  # Notifiers
  #
  # After create
  def notify_on_create
    # Always notify on create
    Notifier.offer_saved(self, 1).deliver
    if check_if_approval_is_required
      Notifier.offer_saved_with_approval(self, 1).deliver
    end     
  end

  # After update
  def notify_on_update
    # Notify only if key values changed
    items_changed = false
    offer_items.each do |i|
      if i.changed?
        items_changed = true
        break
      end
    end
    if self.changed? || items_changed
      Notifier.offer_saved(self, 3).deliver
      if check_if_approval_is_required
        Notifier.offer_saved_with_approval(self, 3).deliver
      end     
    end
  end

  #
  # Helper methods for notifiers
  #
  # Need approval?
  def check_if_approval_is_required
    !offer_request.blank?
  end
end
