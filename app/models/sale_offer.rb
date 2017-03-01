class SaleOffer < ActiveRecord::Base
  include ModelsModule

  belongs_to :client
  belongs_to :payment_method
  belongs_to :sale_offer_status
  belongs_to :project
  belongs_to :store
  belongs_to :work_order
  belongs_to :charge_account
  belongs_to :organization
  belongs_to :contracting_request
  attr_accessible :discount, :discount_pct, :offer_date, :offer_no, :remarks,
                  :client_id, :payment_method_id, :sale_offer_status_id,
                  :project_id, :store_id, :work_order_id, :charge_account_id,
                  :organization_id, :contracting_request_id,
                  :approval_date, :approver
  attr_accessible :sale_offer_items_attributes

  has_many :sale_offer_items, dependent: :destroy
  has_many :sale_offer_item_balances, through: :sale_offer_items
  has_many :delivery_notes
  has_many :delivery_note_items
  has_many :products, through: :sale_offer_items
  has_many :invoices
  has_many :invoice_items

  # Nested attributes
  accepts_nested_attributes_for :sale_offer_items,
                                :reject_if => :all_blank,
                                :allow_destroy => true

  has_paper_trail

  validates_associated :sale_offer_items

  validates :offer_date,        :presence => true
  validates :offer_no,          :presence => true,
                                :length => { :is => 22 },
                                :format => { with: /\A[a-zA-Z\d]+\Z/, message: :code_invalid },
                                :uniqueness => { :scope => :project_id }
  validates :client,            :presence => true
  validates :payment_method,    :presence => true
  validates :sale_offer_status, :presence => true
  validates :project,           :presence => true
  validates :organization,      :presence => true

  # Scopes
  scope :by_no, -> { order(:offer_no) }

  # Callbacks
  before_destroy :check_for_dependent_records
  before_save :update_status_based_on_dates
  before_save :update_dates_based_on_status

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = full_no
    if !self.offer_date.blank?
      full_name += " " + formatted_date(self.offer_date)
    end
    if !self.client.blank?
      full_name += " " + self.client.full_name
    end
    full_name
  end

  def partial_name
    partial_name = full_no
    if !self.client.blank?
      partial_name += " " + self.client.name[0,40]
    end
    partial_name
  end

  def full_no
    # Offer no (Project code & year & sequential number) => PPPPPPPPPPPP-YYYY-NNNNNN
    offer_no.blank? ? "" : offer_no[0..11] + '-' + offer_no[12..15] + '-' + offer_no[16..21]
  end

  #
  # Calculated fields
  #
  def subtotal
    subtotal = 0
    sale_offer_items.each do |i|
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
    sale_offer_items.each do |i|
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
    sale_offer_items.sum("quantity")
  end

  def balance
    balance = 0
    sale_offer_items.each do |i|
      if !i.balance.blank?
        balance += i.balance
      end
    end
    balance
  end

  def unbilled_balance
    sale_offer_item_balances.sum("balance")
  end

  def delivery_avg
    avg, cnt = 0, 0
    sale_offer_items.each do |i|
      if !i.delivery_date.blank?
        avg += Time.parse(i.delivery_date.to_s).to_f
        cnt += 1
      end
    end
    cnt > 0 ? Date.parse(Time.at(avg / cnt).to_s) : nil
  end

  #
  # Class (self) user defined methods
  #
  def self.unbilled(organization, _ordered)
    if !organization.blank?
      if !_ordered
        joins(:sale_offer_item_balances).where('sale_offers.organization_id = ?', organization).group('sale_offers.id').having('sum(sale_offer_item_balances.balance) > ?', 0)
      else
        joins(:sale_offer_item_balances).where('sale_offers.organization_id = ?', organization).group('sale_offers.client_id, sale_offers.offer_no, sale_offers.id').having('sum(sale_offer_item_balances.balance) > ?', 0)
      end
    else
      if !_ordered
        joins(:sale_offer_item_balances).group('sale_offers.id').having('sum(sale_offer_item_balances.balance) > ?', 0)
      else
        joins(:sale_offer_item_balances).group('sale_offers.client_id, sale_offers.offer_no, sale_offers.id').having('sum(sale_offer_item_balances.balance) > ?', 0)
      end
    end
  end

  #
  # Records navigator
  #
  def to_first
    SaleOffer.order("id").first
  end

  def to_prev
    SaleOffer.where("id < ?", id).order("id").last
  end

  def to_next
    SaleOffer.where("id > ?", id).order("id").first
  end

  def to_last
    SaleOffer.order("id").last
  end

  searchable do
    text :offer_no, :approver
    string :offer_no
    integer :id
    integer :payment_method_id
    integer :project_id
    integer :client_id
    integer :store_id
    integer :work_order_id
    integer :charge_account_id
    date :offer_date
    date :approval_date
    integer :organization_id
    integer :sale_offer_status_id
    integer :contracting_request_id
    string :sort_no do
      offer_no
    end
  end

  private

  def check_for_dependent_records
    # Check for delivery notes
    if delivery_notes.count > 0
      errors.add(:base, I18n.t('activerecord.models.sale_offer.check_for_delivery_notes'))
      return false
    end
    # Check for delivery note items
    if delivery_note_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.sale_offer.check_for_delivery_notes'))
      return false
    end
  end

  #
  # Before save (create & update)
  #
  # Status and related approval date
  # 1->pending
  # 2->approved
  # 3->denied
  #
  # Update status
  def update_status_based_on_dates
    if approval_date_was.blank? && !approval_date.blank? && sale_offer_status_id < 2
      self.sale_offer_status_id = 2
    end
    if !approval_date_was.blank? && approval_date.blank? && sale_offer_status_id == 2
      self.sale_offer_status_id = 1
    end
    true
  end

  # Update dates
  def update_dates_based_on_status
    if sale_offer_status_id != sale_offer_status_id_was
      if sale_offer_status_id == 2 && approval_date.blank?
        self.approval_date = Time.now
      end
      if sale_offer_status_id == 1 && !approval_date.blank?
        self.approval_date = nil
      end
    end
    true
  end
end
