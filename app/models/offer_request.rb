class OfferRequest < ActiveRecord::Base
  belongs_to :payment_method
  belongs_to :project
  belongs_to :approved_offer, class_name: 'Offer'
  belongs_to :approver, class_name: 'User'
  belongs_to :store
  belongs_to :work_order
  belongs_to :charge_account
  belongs_to :organization
  attr_accessible :approval_date, :deadline_date, :request_date, :request_no, :remarks,
                  :discount_pct, :discount, :payment_method_id, :project_id, :approved_offer_id,
                  :approver_id, :store_id, :work_order_id, :charge_account_id, :organization_id 
  attr_accessible :offer_request_items_attributes, :offer_request_suppliers_attributes

  has_many :offer_request_items, dependent: :destroy
  has_many :offer_request_suppliers, dependent: :destroy
  has_many :offers

  # Nested attributes
  accepts_nested_attributes_for :offer_request_items,                                 
                                :reject_if => :all_blank,
                                :allow_destroy => true
  accepts_nested_attributes_for :offer_request_suppliers,                                 
                                :reject_if => :all_blank,
                                :allow_destroy => true

  has_paper_trail

  validates_associated :offer_request_items, :offer_request_suppliers

  validates :request_date,    :presence => true
  validates :request_no,      :presence => true,
                              :length => { :is => 22 },
                              :format => { with: /\A[a-zA-Z\d]+\Z/, message: :code_invalid },
                              :uniqueness => { :scope => :organization_id }
  validates :payment_method,  :presence => true
  validates :project,         :presence => true
  validates :organization,    :presence => true

  before_destroy :check_for_dependent_records

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = ""
    if !self.request_no.blank?
      full_name += self.request_no
    end
    if !self.request_date.blank?
      full_name += " " + self.request_date
    end
    if !self.project.blank?
      full_name += " " + self.project.full_name
    end
    full_name
  end

  def full_no
    # Request no (Project code & year & sequential number) => PPPPPPPPPPPP-YYYY-NNNNNN
    request_no.blank? ? "" : request_no[0..11] + '-' + request_no[12..15] + '-' + request_no[16..21]
  end

  #
  # Calculated fields
  #
  def subtotal
    subtotal = 0
    offer_request_items.each do |i|
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
    offer_request_items.each do |i|
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
    offer_request_items.sum("quantity")
  end

  #
  # Records navigator
  #
  def to_first
    OfferRequest.order("request_no").first
  end

  def to_prev
    OfferRequest.where("request_no < ?", request_no).order("request_no").last
  end

  def to_next
    OfferRequest.where("request_no > ?", request_no).order("request_no").first
  end

  def to_last
    OfferRequest.order("request_no").last
  end

  searchable do
    text :request_no
    string :request_no
    integer :payment_method_id
    integer :id, :multiple => true
    integer :project_id, :multiple => true
    integer :store_id
    integer :work_order_id
    integer :charge_account_id
    integer :approved_offer_id
    integer :approver_id
    date :request_date
    date :deadline_date
    date :approval_date
    integer :organization_id
  end

  private

  def check_for_dependent_records
    # Check for offers
    if offers.count > 0
      errors.add(:base, I18n.t('activerecord.models.offer_request.check_for_offers'))
      return false
    end
  end
end
